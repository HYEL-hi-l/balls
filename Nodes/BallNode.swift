//
//  BallNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BallNode: SKSpriteNode {
    let ballType: BallType
    
    init(type: BallType, radius: CGFloat) {
        self.ballType = type
        let texture = SKTexture(imageNamed: "blueberry")
        super.init(texture: texture, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        setupPhysics(radius: radius)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics(radius: CGFloat) {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 0
        physicsBody?.restitution = 1
        physicsBody?.friction = 0
        
        physicsBody?.categoryBitMask = PhysicsCategory.Ball
        physicsBody?.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Block
        physicsBody?.contactTestBitMask = PhysicsCategory.Wall | PhysicsCategory.Block
    }
    
    func applyInitialImpulse(angle: CGFloat, speed: CGFloat) {
        let dx = cos(angle) * speed
        let dy = sin(angle) * speed
        physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
    
    func handleCollision(with node: SKNode) {
        switch ballType {
        case .normal:
            // Implement behavior for normal ball
            break
        case .double:
            // Implement double ball behavior
            break
        }
    }
}
