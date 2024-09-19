//
//  GameStatsNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class GameStatsNode: SKNode {
    private let scoreLabel: SKLabelNode
    private let ballCountLabel: SKLabelNode
    private let roundLabel: SKLabelNode
    
    var score: Int = 0 {
        didSet {
            updateScoreLabel()
        }
    }
    
    var ballCount: Int = 10 {
        didSet {
            updateBallCountLabel()
        }
    }
    
    var round: Int = 1 {
        didSet {
            updateRoundLabel()
        }
    }
    
    init(size: CGSize) {
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: size.width * 0.05, y: size.height * 0.85)
        
        ballCountLabel = SKLabelNode(fontNamed: "Arial-Bold")
        ballCountLabel.fontSize = 24
        ballCountLabel.fontColor = .white
        ballCountLabel.horizontalAlignmentMode = .right
        ballCountLabel.position = CGPoint(x: size.width * 0.95, y: size.height * 0.85)
        
        roundLabel = SKLabelNode(fontNamed: "Arial")
        roundLabel.fontSize = 24
        roundLabel.fontColor = .white
        roundLabel.horizontalAlignmentMode = .center
        roundLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
        
        super.init()
        
        addChild(scoreLabel)
        addChild(ballCountLabel)
        addChild(roundLabel)
        
        updateScoreLabel()
        updateBallCountLabel()
        updateRoundLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    private func updateBallCountLabel() {
        ballCountLabel.text = "Balls: \(ballCount)"
    }
    
    private func updateRoundLabel() {
        roundLabel.text = "Round: \(round)"
    }
    
    func incrementScore(by points: Int = 1) {
        score += points
    }
    
    func incrementBallCount(by count: Int = 1) {
        ballCount += count
    }
    
    func incrementRound(by count: Int = 1) {
        round += count
    }
    
    func reset() {
        score = 0
        ballCount = 1
        round = 1
    }
}
