//
//  PowerUpSlotNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/18/24.
//


import SpriteKit

class PowerUpSlotNode: SKNode {
    private let slotShape: SKShapeNode
    private var powerUpSprite: SKSpriteNode?
    private var glowEffect: SKEffectNode?
    
    var powerUp: PowerUpNode? {
        didSet {
            updatePowerUpDisplay()
        }
    }
    
    init(size: CGSize) {
        slotShape = SKShapeNode(rectOf: size, cornerRadius: 15)
        super.init()
        setup()
        updatePowerUpDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        slotShape.fillColor = .clear
        slotShape.strokeColor = .gray
        slotShape.lineWidth = 2
        addChild(slotShape)
    }
    
    private func updatePowerUpDisplay() {
        powerUpSprite?.removeFromParent()
        
        let texture: SKTexture
        let color: SKColor
        
        if let powerUp = powerUp {
            texture = SKTexture(imageNamed: powerUp.textureName)
            color = .white
        } else {
            texture = SKTexture(imageNamed: "wm_question_mark")
            color = .gray
        }
        
        slotShape.strokeColor = color
        let sprite = SKSpriteNode(texture: texture)
        
        let textureAspectRatio = texture.size().width / texture.size().height
        let slotAspectRatio = slotShape.frame.size.width / slotShape.frame.size.height
        
        if textureAspectRatio > slotAspectRatio {
            sprite.size = CGSize(width: slotShape.frame.size.width * 0.8, height: slotShape.frame.size.width * 0.8 / textureAspectRatio)
        } else {
            sprite.size = CGSize(width: slotShape.frame.size.height * 0.8 * textureAspectRatio, height: slotShape.frame.size.height * 0.8)
        }

        addChild(sprite)
        powerUpSprite = sprite
        
        updateDimState()
    }
    
    func activate() {
        addGlowEffect()
    }
    
    func dimPowerUp(isDimmed: Bool) {
        guard powerUp != nil else { return } 
        powerUpSprite?.alpha = isDimmed ? 0.5 : 1.0
        slotShape.strokeColor = isDimmed ? .white.withAlphaComponent(0.5) : .white
    }
    
    func updateDimState() {
        if powerUp == nil {
            powerUpSprite?.alpha = 0.5
            slotShape.strokeColor = .gray.withAlphaComponent(0.5)
        } else {
            powerUpSprite?.alpha = 1.0
            slotShape.strokeColor = .white
        }
    }
        
    private func addGlowEffect() {
        guard glowEffect == nil, let powerUpSprite = powerUpSprite else { return }
        
        slotShape.strokeColor = .green
        
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 15])
        
        let glowSprite = SKSpriteNode(texture: powerUpSprite.texture, size: powerUpSprite.size)
        glowSprite.color = .green
        glowSprite.colorBlendFactor = 1.0
        glowSprite.setScale(1.3)
        
        glow.addChild(glowSprite)
        insertChild(glow, at: 0)
        
        glowEffect = glow
        
        let pulseAction = SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 0.7, duration: 0.5),
                SKAction.scale(to: 1.3, duration: 0.5)
            ]),
            SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                SKAction.scale(to: 1.2, duration: 0.5)
            ])
        ])
        glow.run(SKAction.repeatForever(pulseAction))
        
        let spritePulseAction = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.3, duration: 0.5)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.2, duration: 0.5)
            ])
        ])
        powerUpSprite.run(SKAction.repeatForever(spritePulseAction))
    }
    
    private func removeGlowEffect() {
        glowEffect?.removeFromParent()
        glowEffect = nil
        powerUpSprite?.removeAllActions()
    }
    
    func removePowerUp() -> PowerUpNode? {
        let removedPowerUp = powerUp
        powerUp = nil
        removeGlowEffect()
        updatePowerUpDisplay()
        return removedPowerUp
    }
}
