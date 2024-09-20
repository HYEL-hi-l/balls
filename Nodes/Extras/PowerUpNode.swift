//
//  PowerUpNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class PowerUpNode: SKShapeNode {
    
    enum PowerUpType {
        case laserSight
        case destructiveTouch
        case doubleDamage
    }
    
    let type: PowerUpType
    let size: CGSize
    var isActive: Bool = false
    var isCollected: Bool = false
    var textureName: String = ""
    private var glowEffect: SKEffectNode?
    
    init(type: PowerUpType, size: CGSize) {
        self.type = type
        self.size = size
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}


// MARK: Helpers
extension PowerUpNode {
    
    private func setup() {
        path = CGPath(roundedRect: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size), cornerWidth: 5, cornerHeight: 5, transform: nil)
        fillColor = .clear
        strokeColor = .red
        lineWidth = 0
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        physicsBody?.collisionBitMask = 0
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        run(SKAction.repeatForever(pulseAction))
        
        addIcon()
    }
    
    private func addIcon() {
        let iconNode = SKSpriteNode(color: .white, size: CGSize(width: size.width * 0.7, height: size.height * 0.7))
        addChild(iconNode)
        
        switch type {
        case .laserSight:
            iconNode.texture = SKTexture(imageNamed: "laser_sight")
            textureName = "laser_sight"
        case .destructiveTouch:
            iconNode.texture = SKTexture(imageNamed: "destructive_touch")
            textureName = "destructive_touch"
        case .doubleDamage:
            iconNode.texture = SKTexture(imageNamed: "double_damage")
            textureName = "double_damage"
        }
        
        guard let texture = iconNode.texture else { return }
        
        let textureAspectRatio = texture.size().width / texture.size().height
        let nodeAspectRatio = size.width / size.height
        
        if textureAspectRatio > nodeAspectRatio {
            iconNode.size = CGSize(width: size.width * 0.8, height: size.width * 0.8 / textureAspectRatio)
        } else {
            iconNode.size = CGSize(width: size.height * 0.8 * textureAspectRatio, height: size.height * 0.8)
        }
        
        iconNode.texture?.filteringMode = .nearest
    }
    
    func collect() {
        isCollected = true
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
