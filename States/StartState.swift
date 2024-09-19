//
//  StartState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit

class GameState: GKState, TapHandler  {
    
    unowned let gameScene: GameScene
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        super.init()
    }
    
    func handleTap(_ touchLocation: CGPoint) { }
    
}


class StartState: GameState {
    
    private var instructionsLabel: SKLabelNode?
    private var startButton: SKSpriteNode?
    private var background: SKSpriteNode?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IdleState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        showInstructions()
        showStartButton()
        animateIntro()
        addInitialBlocks()
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        instructionsLabel?.removeFromParent()
        startButton?.removeFromParent()
        background?.removeFromParent()
    }

    override func handleTap(_ touchLocation: CGPoint) {
        if let button = startButton {
            if button.contains(touchLocation) {
                stateMachine?.enter(IdleState.self)
            }
        }
    }
    
}


// MARK: Helpers
extension StartState {
    
    private func showInstructions() {
        background = SKSpriteNode(color: .darkGray, size: CGSize(width: gameScene.size.width * 0.8, height: gameScene.size.height * 0.2))
        background?.position = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height * 0.43)
        background?.zPosition = 9
        
        let instructions = "Tap and drag to aim.\nRelease to shoot the balls!"
        instructionsLabel = SKLabelNode(text: instructions)
        if let label = instructionsLabel {
            label.numberOfLines = 0
            label.fontName = "Arial"
            label.fontSize = 24
            label.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY - 50)
            label.zPosition = 10
            gameScene.addChild(background!)
            gameScene.addChild(label)
        }
    }
    
    private func showStartButton() {
        startButton = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        if let button = startButton {
            button.position = CGPoint(x: gameScene.frame.midX, y: gameScene.frame.midY - 100)
            
            let buttonLabel = SKLabelNode(text: "Start Game")
            buttonLabel.fontName = "Arial"
            buttonLabel.fontSize = 20
            buttonLabel.fontColor = .black
            buttonLabel.verticalAlignmentMode = .center
            
            button.addChild(buttonLabel)
            button.zPosition = 10

            gameScene.addChild(button)
        }
    }
    
    private func animateIntro() {
        guard !gameScene.textureAtlas.textureNames.isEmpty else { return }
        
        for _ in 0..<100 {
            let randomTextureName = gameScene.textureAtlas.textureNames.randomElement() ?? "watermelon"
            let randomTexture = gameScene.textureAtlas.textureNamed(randomTextureName)
            
            let ball = SKSpriteNode(texture: randomTexture, size: CGSize(width: 20, height: 20))
            ball.position = CGPoint(x: CGFloat.random(in: 0..<gameScene.frame.width),
                                    y: gameScene.frame.height + ball.size.height + CGFloat.random(in: 0..<ball.size.height * 50))
            
            let fallAction = SKAction.moveTo(y: -ball.size.height, duration: Double.random(in: 1.0..<2.0))
            let removeAction = SKAction.removeFromParent()
            ball.run(SKAction.sequence([fallAction, removeAction]))
            
            gameScene.addChild(ball)
        }
    }
    
    private func addInitialBlocks() {
        let blockSize = gameScene.layoutInfo.blockSize
        let columns = gameScene.layoutInfo.columns
        let rows = LayoutInfo.initialRows
        let playAreaTop = gameScene.layoutInfo.playAreaPos.y + (gameScene.layoutInfo.playAreaSize.height / 2)
        let topSpaceOffset = (blockSize.height + 10) * 1.5
        let startY = playAreaTop - topSpaceOffset
        
        let blockCountWeights = [1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5]
        
        for row in 0..<rows {
            let numberOfBlocks = blockCountWeights.randomElement() ?? 3
            
            var availableColumns = Array(0..<columns)
            availableColumns.shuffle()
            
            for i in 0..<numberOfBlocks {
                let col = availableColumns[i]
                let hitPoints = Int.random(in: 1...3)
                let block = BlockNode(size: blockSize, hitPoints: hitPoints)
                
                let x = CGFloat(col) * (blockSize.width + gameScene.layoutInfo.blockSpacing) + blockSize.width / 2 + gameScene.layoutInfo.blockSpacing
                let y = startY - CGFloat(row) * (blockSize.height + gameScene.layoutInfo.blockSpacing)
                
                block.position = CGPoint(x: x, y: y)
                gameScene.blocks.append(block)
                gameScene.addChild(block)
            }
        }
    }
    
}
