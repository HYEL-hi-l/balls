//
//  BallNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class FSBallNode: SKSpriteNode {
    
    var stuckStartTime: TimeInterval?
    var stuckPosition: CGPoint?
    
    init(radius: CGFloat, atlas: SKTextureAtlas) {
        let randomTextureName = atlas.textureNames.randomElement() ?? "blueberry"
        let texture = atlas.textureNamed(randomTextureName)
        super.init(texture: texture, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        setupPhysics(radius: radius)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupPhysics(radius: CGFloat) {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 0
        physicsBody?.restitution = 1
        physicsBody?.friction = 0
        
        physicsBody?.categoryBitMask = FSPhysicsCategory.Ball
        physicsBody?.collisionBitMask = FSPhysicsCategory.Wall | FSPhysicsCategory.Block
        physicsBody?.contactTestBitMask = FSPhysicsCategory.Wall | FSPhysicsCategory.Block | FSPhysicsCategory.BottomLine
    }
    
    func applyInitialImpulse(angle: CGFloat, speed: CGFloat) {
        let dx = cos(angle) * speed
        let dy = sin(angle) * speed
        physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
    
}
