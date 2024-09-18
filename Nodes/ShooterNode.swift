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
    
    private let minAngleOffset: CGFloat = .pi / 36
    
    private(set) var aimAngle: CGFloat = .pi / 2 {
        didSet {
            updateAimLine()
        }
    }
    
    init(size: CGSize) {
        shooterBody = SKSpriteNode(texture: SKTexture(imageNamed: "happy"), size: size)

        aimLine = TargetLineNode()
        aimLine.isHidden = true
        
        super.init()
        
        addChild(shooterBody)
        addChild(aimLine)
        
        updateAimLine()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
        
        let distance = hypot(dx, dy)
        aimLine.expandLine(from: position, to: point, angle: aimAngle)
    }
    
    private func updateAimLine() {
        let lineLength: CGFloat = 50
        aimLine.updateLine(length: lineLength, angle: aimAngle)
    }
    
    func showAimLine() {
        aimLine.showLine()
    }
    
    func hideAimLine() {
        aimLine.hideLine()
    }
    
    func shoot(_ ball: BallNode) {
        ball.applyInitialImpulse(angle: aimAngle, speed: 10)
        hideAimLine()
    }
    
    func reset() {
        self.aimAngle = .pi / 2
    }
}
