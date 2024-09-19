//
//  GameOverState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class GameOverState: GameState {
    
    private var gameOverNode: SKNode?
    private var replayButton: SKSpriteNode?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is StartState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("GameOverState")
        super.didEnter(from: previousState)
        showGameOverScreen()
    }
    
    override func willExit(to nextState: GKState) {
        gameOverNode?.removeFromParent()
    }

    override func handleTap(_ touchLocation: CGPoint) {
        if let replayButton = replayButton, replayButton.contains(touchLocation) {
            resetGame()
            stateMachine?.enter(StartState.self)
        }
    }
    
}


// MARK: Helpers
extension GameOverState {
    
    private func resetGame() {
        gameScene.reset()
    }
    
    private func showGameOverScreen() {
        guard let gameInfo = gameScene.gameInfo else { return }
        gameOverNode = SKNode()
        
        let background = SKSpriteNode(color: .darkGray, size: CGSize(width: gameScene.size.width * 0.7, height: gameScene.size.height * 0.5))
        background.position = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2)
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Arial-Bold"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY + 100)
        
        let scoreLabel = SKLabelNode(text: "Score: \(gameInfo.score)")
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY)
        
        let ballCountLabel = SKLabelNode(text: "Balls: \(gameInfo.ballCount)")
        ballCountLabel.fontName = "Arial"
        ballCountLabel.fontSize = 30
        ballCountLabel.fontColor = .white
        ballCountLabel.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY - 50)
        
        replayButton = SKSpriteNode(color: .lightGray, size: CGSize(width: 150, height: 50))
        replayButton?.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY - 150)
        
        let replayLabel = SKLabelNode(text: "Replay")
        replayLabel.fontName = "Arial"
        replayLabel.fontSize = 20
        replayLabel.fontColor = .black
        replayLabel.verticalAlignmentMode = .center
        replayButton?.addChild(replayLabel)
        
        gameOverNode?.addChild(background)
        gameOverNode?.addChild(gameOverLabel)
        gameOverNode?.addChild(scoreLabel)
        gameOverNode?.addChild(ballCountLabel)
        if let replayButton = replayButton {
            gameOverNode?.addChild(replayButton)
        }
        
        if let gameOverNode = gameOverNode {
            gameOverNode.zPosition = 1000
            gameScene.addChild(gameOverNode)
        }
    }
    
}
