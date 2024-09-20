//
//  BallCountNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class FSBallCountNode: SKNode {
    private let countLabel: SKLabelNode
    
    init(fontSize: CGFloat = 14) {
        countLabel = SKLabelNode(fontNamed: "Arial Bold")
        countLabel.fontSize = fontSize
        countLabel.fontColor = UIColor(hex: "FAFAFA")
        countLabel.verticalAlignmentMode = .center
        
        super.init()
        
        addChild(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateCount(_ count: Int) {
        if count < 1 {
            countLabel.text = ""
        } else {
            countLabel.text = "x\(count)"
        }
    }
}
