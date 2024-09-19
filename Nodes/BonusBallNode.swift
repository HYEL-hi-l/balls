//
//  BonusBallNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BonusBallNode: SKShapeNode {
    
    private let radius: CGFloat
    public var isCollected: Bool = false
    
    init(position: CGPoint, radius: CGFloat) {
        self.radius = radius
        super.init()
        self.position = position
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        fillColor = .white
        strokeColor = .cyan
        lineWidth = 2
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.BonusBall
        physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        physicsBody?.collisionBitMask = 0
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        run(SKAction.repeatForever(pulseAction))
    }
    
    func collect() {
        let scaleAction = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        
        run(SKAction.sequence([SKAction.group([scaleAction, fadeAction]), removeAction]))
    }
    
    func pauseAnimation() {
        isPaused = true
    }
    
    func resumeAnimation() {
        isPaused = false
    }
}
