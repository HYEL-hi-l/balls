//
//  BlackNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BlockNode: SKShapeNode {
    var hitPoints: Int
    
    init(size: CGSize, hitPoints: Int) {
        self.hitPoints = hitPoints
        super.init()
        
        let rect = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)
        path = CGPath(rect: rect, transform: nil)
        
        fillColor = colorForHitPoints(hitPoints)
        strokeColor = .clear
        lineWidth = 4
        
        setupPhysics(size: size)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics(size: CGSize) {
        physicsBody = SKPhysicsBody(rectangleOf: size, center: .zero)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Block
        physicsBody?.collisionBitMask = PhysicsCategory.Ball
        physicsBody?.contactTestBitMask = PhysicsCategory.Ball
    }
    
    private func setupLabel() {
        let label = SKLabelNode(text: "\(hitPoints)")
        label.fontName = "Arial-Bold"
        label.fontSize = 15
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: frame.maxX - label.frame.width, y: frame.minY + label.frame.height)
        addChild(label)
    }
    
    func hit() {
        hitPoints -= 1
        if hitPoints <= 0 {
            removeFromParent()
        } else {
            fillColor = colorForHitPoints(hitPoints)
            if let label = children.first as? SKLabelNode {
                label.text = "\(hitPoints)"
            }
        }
    }
    
    private func colorForHitPoints(_ points: Int) -> SKColor {
        switch points {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }
}
