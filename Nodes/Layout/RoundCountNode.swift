//
//  RoundCountNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class RoundCountNode: SKNode {
    private let roundLabel: SKLabelNode
    private let backgroundNode: SKShapeNode
    
    var round: Int = 1 {
        didSet {
            updateRoundLabel()
        }
    }
    
    init(size: CGSize) {
        let backgroundWidth: CGFloat = size.width
        let backgroundHeight: CGFloat = size.height
        backgroundNode = SKShapeNode(rectOf: CGSize(width: backgroundWidth, height: backgroundHeight), cornerRadius: 20)
//        backgroundNode.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        backgroundNode.fillColor = .clear
        backgroundNode.strokeColor = .white
        backgroundNode.lineWidth = 2
        
        roundLabel = SKLabelNode(fontNamed: "Arial Bold")
        roundLabel.fontSize = 33
        roundLabel.fontColor = .white
        roundLabel.verticalAlignmentMode = .center
        roundLabel.position = CGPoint(x: 0, y: 0)
        
        super.init()
        
        addChild(backgroundNode)
        backgroundNode.addChild(roundLabel)
        
        updateRoundLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateRoundLabel() {
        roundLabel.text = "\(round)"
    }
    
    func incrementRound(by count: Int = 1) {
        round += count
    }
    
    func reset() {
        round = 1
    }
}
