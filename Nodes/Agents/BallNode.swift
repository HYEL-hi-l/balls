//
//  BallNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BallNode: SKSpriteNode {
    let ballType: BallType
    var stuckStartTime: TimeInterval?
    var stuckPosition: CGPoint?
    
    init(type: BallType, radius: CGFloat, atlas: SKTextureAtlas) {
        self.ballType = type
        let randomTextureName = atlas.textureNames.randomElement() ?? "blueberry"
        let texture = atlas.textureNamed(randomTextureName)
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
        physicsBody?.contactTestBitMask = PhysicsCategory.Wall | PhysicsCategory.Block | PhysicsCategory.BottomLine
    }
    
    func applyInitialImpulse(angle: CGFloat, speed: CGFloat) {
        let dx = cos(angle) * speed
        let dy = sin(angle) * speed
        physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
    
}
