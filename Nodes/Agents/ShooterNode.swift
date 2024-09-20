//
//  ShooterNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class ShooterNode: SKNode {
    let shooterBody: SKSpriteNode
    private let aimLine: TargetLineNode
    private var laserSight: SKShapeNode?
    private var thunder: SKSpriteNode?
    
    private let minAngleOffset: CGFloat = .pi / 36
    private let maxBounces: Int = 5
    private let ballRadius: CGFloat = 8
    
    private let wiggleFrequency: CGFloat = 0.2
    private let wiggleAmplitude: CGFloat = 3.0
    private var wiggleOffset: CGFloat = 0.0
    private let wiggleSpeed: CGFloat = 8.0
    var isWiggleEnabled: Bool = true
    
    private var lastUpdateTime: TimeInterval = 0
    
    private(set) var aimAngle: CGFloat = .pi / 2 {
        didSet {
            updateLaserSight()
        }
    }
    
    init(size: CGSize, ballRadius: CGFloat) {
        shooterBody = SKSpriteNode(texture: SKTexture(imageNamed: "raspberry"))
        aimLine = TargetLineNode(ballRadius: ballRadius)
        aimLine.isHidden = true
        
        super.init()
        
        addChild(shooterBody)
        addChild(aimLine)
        
        setupLaserSight()
        setupThunder()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func shoot(_ ball: BallNode) {
        ball.applyInitialImpulse(angle: aimAngle, speed: 8)
    }
    
    func reset() {
        hideLaserSight()
        shooterBody.texture = SKTexture(imageNamed: "raspberry")
    }
    
    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if isWiggleEnabled {
            wiggleOffset += CGFloat(deltaTime) * wiggleSpeed
            if wiggleOffset > .pi * 2 {
                wiggleOffset -= .pi * 2
            }
        }
        
        updateLaserSight()
    }
}

// MARK: Aiming
extension ShooterNode {
    func showAimLine() {
        aimLine.showLine()
    }
    
    func hideAimLine() {
        aimLine.hideLine()
    }
    
    func aim(toward point: CGPoint) {
        let dx = point.x - position.x
        let dy = max(point.y - position.y, 1)
        
        var angle = atan2(dy, dx)
        
        if angle < minAngleOffset {
            angle = minAngleOffset
        } else if angle > .pi - minAngleOffset {
            angle = .pi - minAngleOffset
        }
        
        aimAngle = angle
        aimLine.expandLine(from: position, to: point, angle: aimAngle)
        updateShooterRotation()
    }
    
    private func updateShooterRotation() {
        let rotation = aimAngle - .pi / 2
        shooterBody.zRotation = rotation
    }
    
}


// MARK: Thunder Sprite
extension ShooterNode {
    
    private func setupThunder() {
        thunder = SKSpriteNode(texture: SKTexture(imageNamed: "thunder"))
        thunder?.size = CGSize(width: shooterBody.size.width * 0.4, height: shooterBody.size.height * 0.4)
        thunder?.position = CGPoint(x: shooterBody.size.width / 2, y: -shooterBody.size.height / 2)
        thunder?.zPosition = 1
        thunder?.isHidden = true
        addChild(thunder!)
    }
    
    func showThunder() {
        thunder?.isHidden = false
        thunder?.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])) {
            self.startThunderShakeAnimation()
        }
    }
    
    func hideThunder() {
        thunder?.isHidden = true
        thunder?.removeAction(forKey: "thunderShake")
    }
    
    private func startThunderShakeAnimation() {
        let shakeRight = SKAction.moveBy(x: 2, y: 0, duration: 0.05)
        let shakeLeft = SKAction.moveBy(x: -2, y: 0, duration: 0.05)
        let shakeUp = SKAction.moveBy(x: 0, y: 2, duration: 0.05)
        let shakeDown = SKAction.moveBy(x: 0, y: -2, duration: 0.05)
        
        let shakeSequence = SKAction.sequence([
            shakeRight, shakeLeft, shakeLeft, shakeRight,
            shakeUp, shakeDown, shakeDown, shakeUp
        ])
        
        let loopShake = SKAction.repeatForever(shakeSequence)
        thunder?.run(loopShake, withKey: "thunderShake")
    }

}

// MARK: Laser Sight
extension ShooterNode {
    
    private func setupLaserSight() {
        laserSight = SKShapeNode()
        laserSight?.strokeColor = .red
        laserSight?.lineWidth = 3
        laserSight?.alpha = 0.7
        laserSight?.zPosition = -1
        laserSight?.isHidden = true
        addChild(laserSight!)
    }
    
    func showLaserSight() {
        laserSight?.isHidden = false
    }
    
    func hideLaserSight() {
        laserSight?.isHidden = true
    }
    
    private func updateLaserSight() {
        guard let scene = scene as? GameScene else { return }
        
        let path = CGMutablePath()
        path.move(to: .zero)
        
        var currentPoint = CGPoint.zero
        var currentAngle = aimAngle
        var totalDistance: CGFloat = 0
        
        for _ in 0..<maxBounces {
            let (nextPoint, nextAngle, hitBlock) = calculateNextPoint(from: currentPoint, angle: currentAngle, in: scene)
            
            drawWavyLineSegment(from: currentPoint, to: nextPoint, startDistance: totalDistance, path: path)
            
            totalDistance += currentPoint.distance(to: nextPoint)
            
            if nextPoint.y <= -position.y + ballRadius {
                break
            }
            
            currentPoint = nextPoint
            currentAngle = nextAngle
            
            if hitBlock {
                currentPoint = CGPoint(x: nextPoint.x + cos(nextAngle) * 0.1, y: nextPoint.y + sin(nextAngle) * 0.1)
            }
        }
        
        laserSight?.path = path
    }
       
    private func drawWavyLineSegment(from start: CGPoint, to end: CGPoint, startDistance: CGFloat, path: CGMutablePath) {
        let segmentLength = start.distance(to: end)
        let direction = CGPoint(x: end.x - start.x, y: end.y - start.y).normalized()
        let perpendicular = CGPoint(x: -direction.y, y: direction.x)
        
        let steps = Int(segmentLength / 5) + 1
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let segmentPoint = CGPoint(x: start.x + direction.x * segmentLength * t,
                                       y: start.y + direction.y * segmentLength * t)
            
            var wavePoint = segmentPoint
            if isWiggleEnabled {
                let waveOffset = sin((startDistance + segmentLength * t) * wiggleFrequency + wiggleOffset) * wiggleAmplitude
                wavePoint = CGPoint(x: segmentPoint.x + perpendicular.x * waveOffset,
                                    y: segmentPoint.y + perpendicular.y * waveOffset)
            }
            
            if i == 0 {
                path.move(to: wavePoint)
            } else {
                path.addLine(to: wavePoint)
            }
        }
    }

    private func calculateNextPoint(from point: CGPoint, angle: CGFloat, in scene: GameScene) -> (point: CGPoint, angle: CGFloat, hitBlock: Bool) {
        let dx = cos(angle)
        let dy = sin(angle)
        
        let leftWallX: CGFloat = -position.x + ballRadius
        let rightWallX: CGFloat = scene.size.width - position.x - ballRadius
        let bottomLineY: CGFloat = -position.y + ballRadius
        
        var t: CGFloat = .greatestFiniteMagnitude
        var nextPoint = CGPoint.zero
        var nextAngle = angle
        var hitBlock = false
        var hitNormal: CGPoint = .zero
        
        if dx < 0 {
            let tLeft = (leftWallX - point.x) / dx
            if tLeft < t {
                t = tLeft
                nextPoint = CGPoint(x: leftWallX, y: point.y + t * dy)
                hitNormal = CGPoint(x: 1, y: 0)
            }
        }
        
        if dx > 0 {
            let tRight = (rightWallX - point.x) / dx
            if tRight < t {
                t = tRight
                nextPoint = CGPoint(x: rightWallX, y: point.y + t * dy)
                hitNormal = CGPoint(x: -1, y: 0)
            }
        }
        
        if dy < 0 {
            let tBottom = (bottomLineY - point.y) / dy
            if tBottom < t {
                t = tBottom
                nextPoint = CGPoint(x: point.x + t * dx, y: bottomLineY)
                hitNormal = CGPoint(x: 0, y: 1)
            }
        }
        
        for block in scene.blocks {
            let blockFrame = convert(block.frame, from: scene)
            if let collision = checkCircleRectCollision(center: point, direction: CGPoint(x: dx, y: dy), radius: ballRadius, rect: blockFrame) {
                if collision.t < t {
                    t = collision.t
                    nextPoint = collision.point
                    hitNormal = collision.normal
                    hitBlock = true
                }
            }
        }
        
        if hitNormal != .zero {
            let incidentVector = CGPoint(x: dx, y: dy)
            nextAngle = calculateBounceAngle(incidentVector: incidentVector, normal: hitNormal)
        }
        
        if t == .greatestFiniteMagnitude {
            nextPoint = CGPoint(x: point.x + dx * 1000, y: point.y + dy * 1000)
        }
        
        return (nextPoint, nextAngle, hitBlock)
    }
    
    private func checkCircleRectCollision(center: CGPoint, direction: CGPoint, radius: CGFloat, rect: CGRect) -> (point: CGPoint, normal: CGPoint, t: CGFloat)? {
        let expandedRect = rect.insetBy(dx: -radius, dy: -radius)
        guard let rectCollision = rayIntersectsRect(origin: center, direction: direction, rect: expandedRect) else {
            return nil
        }
        
        let corners = [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.minX, y: rect.maxY),
            CGPoint(x: rect.maxX, y: rect.maxY)
        ]
        
        for corner in corners {
            if let cornerCollision = rayIntersectsCircle(center: corner, radius: radius, rayOrigin: center, rayDirection: direction) {
                if cornerCollision.t < rectCollision.t {
                    let normal = CGPoint(x: cornerCollision.point.x - corner.x, y: cornerCollision.point.y - corner.y).normalized()
                    return (cornerCollision.point, normal, cornerCollision.t)
                }
            }
        }
        
        return rectCollision
    }
    
    private func rayIntersectsRect(origin: CGPoint, direction: CGPoint, rect: CGRect) -> (point: CGPoint, normal: CGPoint, t: CGFloat)? {
        let minT = CGPoint(x: (rect.minX - origin.x) / direction.x,
                           y: (rect.minY - origin.y) / direction.y)
        let maxT = CGPoint(x: (rect.maxX - origin.x) / direction.x,
                           y: (rect.maxY - origin.y) / direction.y)
        
        let tMin = max(min(minT.x, maxT.x), min(minT.y, maxT.y))
        let tMax = min(max(minT.x, maxT.x), max(minT.y, maxT.y))
        
        if tMax < 0 || tMin > tMax {
            return nil
        }
        
        let t = tMin > 0 ? tMin : tMax
        let hitPoint = CGPoint(x: origin.x + direction.x * t, y: origin.y + direction.y * t)
        
        var normal: CGPoint
        if abs(hitPoint.x - rect.minX) < 0.001 {
            normal = CGPoint(x: -1, y: 0)
        } else if abs(hitPoint.x - rect.maxX) < 0.001 {
            normal = CGPoint(x: 1, y: 0)
        } else if abs(hitPoint.y - rect.minY) < 0.001 {
            normal = CGPoint(x: 0, y: -1)
        } else {
            normal = CGPoint(x: 0, y: 1)
        }
        
        return (hitPoint, normal, t)
    }
    
    private func rayIntersectsCircle(center: CGPoint, radius: CGFloat, rayOrigin: CGPoint, rayDirection: CGPoint) -> (point: CGPoint, t: CGFloat)? {
        let toCircle = CGPoint(x: center.x - rayOrigin.x, y: center.y - rayOrigin.y)
        let a = rayDirection.x * rayDirection.x + rayDirection.y * rayDirection.y
        let b = -2 * (rayDirection.x * toCircle.x + rayDirection.y * toCircle.y)
        let c = toCircle.x * toCircle.x + toCircle.y * toCircle.y - radius * radius
        
        let discriminant = b * b - 4 * a * c
        if discriminant < 0 {
            return nil
        }
        
        let t = (-b - sqrt(discriminant)) / (2 * a)
        if t < 0 {
            return nil
        }
        
        let point = CGPoint(x: rayOrigin.x + rayDirection.x * t, y: rayOrigin.y + rayDirection.y * t)
        return (point, t)
    }
    
    private func calculateBounceAngle(incidentVector: CGPoint, normal: CGPoint) -> CGFloat {
        let dot = incidentVector.x * normal.x + incidentVector.y * normal.y
        let reflectedX = incidentVector.x - 2 * dot * normal.x
        let reflectedY = incidentVector.y - 2 * dot * normal.y
        return atan2(reflectedY, reflectedX)
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func normalized() -> CGPoint {
        let length = sqrt(x*x + y*y)
        return CGPoint(x: x / length, y: y / length)
    }
}
