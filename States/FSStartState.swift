//
//  StartState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class FSGameState: GKState, FSTapHandler  {
    
    unowned let gameScene: FSGameScene
    
    init(gameScene: FSGameScene) {
        self.gameScene = gameScene
        super.init()
    }
    
    func handleTap(_ touchLocation: CGPoint) { }
    
}

class FSStartState: FSGameState {
    
    private var instructionsLabel1: SKLabelNode?
    private var instructionsLabel2: SKLabelNode?
    private var currentInstructionSet: Int = 0
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FSIdleState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        showFirstInstructionSet()
        animateIntro()
        addInitialBlocks()
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        instructionsLabel1?.removeFromParent()
        instructionsLabel2?.removeFromParent()
    }

    override func handleTap(_ touchLocation: CGPoint) {
        if currentInstructionSet == 0 {
            showSecondInstructionSet()
        } else if currentInstructionSet == 1 {
            stateMachine?.enter(FSIdleState.self)
        }
    }
    
}

// MARK: Helpers
extension FSStartState {

    private func showFirstInstructionSet() {
        currentInstructionSet = 0
        
        let instruction1 = "Drag to aim. Release to shoot the fruit!"
        let instruction2 = "Tap anywhere to continue..."
        
        instructionsLabel1 = SKLabelNode(text: instruction1)
        instructionsLabel2 = SKLabelNode(text: instruction2)
        
        if let label1 = instructionsLabel1, let label2 = instructionsLabel2 {
            label1.fontName = "Arial"
            label1.fontSize = 18
            label1.fontColor = .gray
            label1.position = CGPoint(x: gameScene.frame.midX, y: gameScene.layoutInfo.playAreaPos.y - gameScene.layoutInfo.playAreaSize.height * 0.15)
            label1.horizontalAlignmentMode = .center
            label1.zPosition = 10
            gameScene.addChild(label1)
            
            label2.fontName = "Arial Italic"
            label2.fontSize = 12
            label2.fontColor = .lightGray
            label2.position = CGPoint(x: gameScene.frame.midX, y: label1.position.y - 30)
            label2.horizontalAlignmentMode = .center
            label2.zPosition = 10
            gameScene.addChild(label2)
            
            let pulseOut = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
            let pulseIn = SKAction.fadeAlpha(to: 0.6, duration: 1.0)
            let pulse = SKAction.sequence([pulseOut, pulseIn])
            let repeatPulse = SKAction.repeatForever(pulse)
            label2.run(repeatPulse)
        }
    }
    
    private func showSecondInstructionSet() {
        instructionsLabel1?.removeFromParent()
        instructionsLabel2?.removeFromParent()
        
        currentInstructionSet = 1
        
        let instruction1 = "Don't let the blocks hit the bottom!"
        let instruction2 = "Tap anywhere to start..."
        
        instructionsLabel1 = SKLabelNode(text: instruction1)
        instructionsLabel2 = SKLabelNode(text: instruction2)
        
        if let label1 = instructionsLabel1, let label2 = instructionsLabel2 {
            label1.fontName = "Arial"
            label1.fontSize = 18
            label1.fontColor = .gray
            label1.position = CGPoint(x: gameScene.frame.midX, y: gameScene.layoutInfo.playAreaPos.y - gameScene.layoutInfo.playAreaSize.height * 0.15)
            label1.horizontalAlignmentMode = .center
            label1.zPosition = 10
            gameScene.addChild(label1)
            
            label2.fontName = "Arial Italic"
            label2.fontSize = 12
            label2.fontColor = .lightGray
            label2.position = CGPoint(x: gameScene.frame.midX, y: label1.position.y - 30)
            label2.horizontalAlignmentMode = .center
            label2.zPosition = 10
            gameScene.addChild(label2)
            
            let pulseOut = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
            let pulseIn = SKAction.fadeAlpha(to: 0.6, duration: 1.0)
            let pulse = SKAction.sequence([pulseOut, pulseIn])
            let repeatPulse = SKAction.repeatForever(pulse)
            label2.run(repeatPulse)
        }
    }
    
    private func animateIntro() {
        guard !gameScene.ballsAtlas.textureNames.isEmpty else { return }
        
        for _ in 0..<100 {
            let randomTextureName = gameScene.ballsAtlas.textureNames.randomElement() ?? "watermelon"
            let randomTexture = gameScene.ballsAtlas.textureNamed(randomTextureName)
            
            let ball = SKSpriteNode(texture: randomTexture, size: CGSize(width: 20, height: 20))
            ball.position = CGPoint(x: CGFloat.random(in: 0..<gameScene.frame.width),
                                    y: gameScene.frame.height + ball.size.height + CGFloat.random(in: 0..<ball.size.height * 50))
            ball.zPosition = 10000
            
            let fallAction = SKAction.moveTo(y: -ball.size.height, duration: Double.random(in: 1.0..<2.0))
            let removeAction = SKAction.removeFromParent()
            ball.run(SKAction.sequence([fallAction, removeAction]))
            
            gameScene.addChild(ball)
        }
    }
    
    private func addInitialBlocks() {
        let blockSize = gameScene.layoutInfo.blockSize
        let columns = gameScene.layoutInfo.columns
        let rows = FSLayoutInfo.initialRows
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
                let block = FSBlockNode(size: blockSize, hitPoints: hitPoints, atlas: gameScene.blocksAtlas)
                
                let x = CGFloat(col) * (blockSize.width + gameScene.layoutInfo.blockSpacing) + blockSize.width / 2 + gameScene.layoutInfo.blockSpacing
                let y = startY - CGFloat(row) * (blockSize.height + gameScene.layoutInfo.blockSpacing)
                
                block.position = CGPoint(x: x, y: y)
                gameScene.blocks.append(block)
                gameScene.addChild(block)
            }
        }
    }
    
}
