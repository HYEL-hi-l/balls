//
//  BonusBallNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BonusBallNode: SKSpriteNode {
    
    private let radius: CGFloat
    public var isCollected: Bool = false
    private var glowEffect: SKEffectNode!
    
    init(position: CGPoint, radius: CGFloat, atlas: SKTextureAtlas) {
        self.radius = radius
//        let texture = SKTexture(imageNamed: "bonus_ball")
        let randomTextureName = atlas.textureNames.randomElement() ?? "blueberry"
        let texture = atlas.textureNamed(randomTextureName)
        super.init(texture: texture, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        self.position = position
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.BonusBall
        physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        physicsBody?.collisionBitMask = 0
        
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        run(SKAction.repeatForever(pulseAction))
    }
    
    func collect() {
        let plusOneLabel = SKLabelNode(text: "+1")
        plusOneLabel.fontName = "Arial"
        plusOneLabel.fontSize = 16
        plusOneLabel.fontColor = .white
        plusOneLabel.position = CGPoint(x: frame.width * 0.4, y: frame.height * 0.4)
        addChild(plusOneLabel)
        
        let moveUp = SKAction.moveBy(x: 5, y: 5, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        plusOneLabel.run(SKAction.sequence([moveUp, fadeOut])) {
            plusOneLabel.removeFromParent()
        }
        
        // Animate bonus ball
        let scaleAction = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        
        run(SKAction.sequence([
            SKAction.group([scaleAction, fadeAction]),
            removeAction
        ]))
    }
    
    func pauseAnimation() {
        isPaused = true
    }
    
    func resumeAnimation() {
        isPaused = false
    }
}
