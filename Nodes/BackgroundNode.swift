//
//  BackgroundNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BackgroundNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "balls_bg")
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        zPosition = -1
    }
}
