//
//  PlayAreaNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class PlayAreaNode: SKShapeNode {
    let playableRect: CGRect
    
    init(size: CGSize, position: CGPoint) {
        playableRect = CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        super.init()
        
        let path = CGPath(rect: playableRect, transform: nil)
        self.path = path
        self.position = position
        fillColor = .black
        strokeColor = .clear
        lineWidth = 2
        
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(edgeLoopFrom: self.path!)
        physicsBody.friction = 0
        physicsBody.restitution = 1
        physicsBody.linearDamping = 0
        physicsBody.angularDamping = 0
        self.physicsBody = physicsBody
    }
    
    func isInPlayableArea(_ point: CGPoint) -> Bool {
        return playableRect.contains(convert(point, from: parent!))
    }
}
