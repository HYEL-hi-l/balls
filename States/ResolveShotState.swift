//
//  ResolveShotState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class ResolveShotState: GameState {
    override func didEnter(from previousState: GKState?) {
        print("ResolveShot")
        
        gameScene.fastForwardNode?.cancelShow()
        gameScene.fastForwardNode?.resetSpeed()

        moveShooterToLastBottomBall()
        gameScene.clearActiveBalls()
        shiftBlocksDown()
        addNewBlockRow()
        updateGameInfo()
        
        if isGameOver() {
            stateMachine?.enter(GameOverState.self)
        } else {
            stateMachine?.enter(IdleState.self)
        }
    }
    
    private func moveShooterToLastBottomBall() {
        let bottomY = gameScene.shooter.position.y
        if let lastBottomBall = gameScene.activeBalls.last(where: { $0.position.y <= bottomY }) {
            let newX = max(min(lastBottomBall.position.x, gameScene.size.width - 20), 20)
            gameScene.shooter.position.x = newX
        }
    }
    
    private func shiftBlocksDown() {
        let shiftDistance: CGFloat = gameScene.layoutInfo.blockSize.height + gameScene.layoutInfo.blockSpacing
        print(gameScene.blocks.count)
        for block in gameScene.blocks {
            block.run(SKAction.moveBy(x: 0, y: -shiftDistance, duration: 0.3))
        }
    }
    
    private func addNewBlockRow() {
        let blockSize = gameScene.layoutInfo.blockSize
        let columns = gameScene.layoutInfo.columns
        let playAreaTop = gameScene.layoutInfo.playAreaPos.y + (gameScene.layoutInfo.playAreaSize.height / 2)
        let topSpaceOffset = (blockSize.height + 10) * 2
        let topY = playAreaTop - topSpaceOffset
        
        let currentRound = gameScene.gameInfo?.round ?? 1
        
        let blockCountWeights = [1, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 6, 6, 7]
        let numberOfBlocks = blockCountWeights.randomElement() ?? 4
        
        var availableColumns = Array(0..<columns)
        availableColumns.shuffle()
        
        let hasDoubleBlock = Bool.random()
        let doubleBlockIndex = hasDoubleBlock ? Int.random(in: 0..<numberOfBlocks) : nil
        
        for i in 0..<numberOfBlocks {
            let col = availableColumns[i]
            
            var hitPoints = currentRound
            
            if let doubleIndex = doubleBlockIndex, i == doubleIndex {
                hitPoints = currentRound * 2
            }
            
            let blockNode = BlockNode(size: blockSize, hitPoints: hitPoints)
            
            let x = CGFloat(col) * (blockSize.width + gameScene.layoutInfo.blockSpacing) + gameScene.layoutInfo.blockSpacing
            let y = topY
            
            blockNode.position = CGPoint(x: x, y: y)
            gameScene.addChild(blockNode)
            gameScene.blocks.append(blockNode)
        }
    }
    
    private func updateGameInfo() {
        gameScene.gameInfo?.incrementRound()
        gameScene.gameStats.incrementRound()
        gameScene.gameInfo?.incrementBallCount(by: 1)
    }
    
    private func isGameOver() -> Bool {
        let bottomLineY = gameScene.shooter.position.y
        return gameScene.blocks.contains { block in
            let blockBottom = block.position.y - block.frame.height
            return blockBottom <= bottomLineY
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IdleState.Type || stateClass is GameOverState.Type
    }
}
