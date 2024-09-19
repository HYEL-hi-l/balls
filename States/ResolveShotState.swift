//
//  ResolveShotState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class ResolveShotState: GameState {
    
    private var firstBottomBallPosition: CGPoint?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IdleState.Type || stateClass is GameOverState.Type
    }
    
    override func didEnter(from previousState: GKState?) {        
        gameScene.fastForwardNode?.cancelShow()
        gameScene.gameInfo?.ballSpeedMultiplier = 1
        gameScene.fastForwardNode?.resetSpeed()

        collectBallsAndMoveShooter() {
            self.shiftBlocksDown() {
                if self.isGameOver() {
                    self.stateMachine?.enter(GameOverState.self)
                } else {
                    self.addNewBlockRow() {
                        self.updateGameInfo()
                        self.gameScene.clearAllBalls()
                        self.gameScene.shooter.shooterBody.isHidden = false
                        self.stateMachine?.enter(IdleState.self)
                    }
                }
            }
        }
    }
    
}


// MARK: Helpers
extension ResolveShotState {
    
    private func isGameOver() -> Bool {
        let gameOverLineY = gameScene.layoutInfo.gameOverLineY
        return gameScene.blocks.contains { block in
            let blockBottom = block.position.y - block.frame.height
            return blockBottom <= gameOverLineY
        }
    }
    
    private func updateGameInfo() {
        gameScene.gameInfo?.incrementRound()
        gameScene.gameStats.incrementRound()
        gameScene.gameInfo?.incrementBallCount(by: 1)
        gameScene.remainingBalls = gameScene.gameInfo?.ballCount ?? 1
        gameScene.updateBallCountDisplay()
    }
    
    private func collectBallsAndMoveShooter(completion: @escaping () -> ()) {
        guard let firstBall = gameScene.firstBallToHitBottom else {
            print("Warning: No ball hit the bottom line")
            completion()
            return
        }

        let ballsToCollect = gameScene.balls.filter { $0 != firstBall }
        
        animateBallCollection(ballsToCollect, to: firstBall.position) {
            self.moveShooterToPosition(firstBall.position) {
                self.gameScene.firstBallToHitBottom = nil
                completion()
            }
        }
    }
    
    private func animateBallCollection(_ balls: [SKNode], to position: CGPoint, completion: @escaping () -> ()) {
        if balls.count < 1 {
            completion()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        for (index, ball) in balls.enumerated() {
            dispatchGroup.enter()
            
            let delay = TimeInterval(index) * 0.05
            let moveAction = SKAction.move(to: position, duration: 0.2)
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                moveAction,
                fadeOutAction,
                SKAction.removeFromParent()
            ])
            ball.run(sequence) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func moveShooterToPosition(_ position: CGPoint, completion: @escaping () -> ()) {
        let newX = max(min(position.x, gameScene.size.width - 20), 20)
        let moveAction = SKAction.moveTo(x: newX, duration: 0.3)
        gameScene.shooter.run(moveAction) {
            completion()
            self.gameScene.updateBallCountNodePosition()
        }
    }
    
}


// MARK: Blocks
extension ResolveShotState {
    
    private func shiftBlocksDown(completion: @escaping () -> ()) {
        let shiftDistance: CGFloat = gameScene.layoutInfo.blockSize.height + gameScene.layoutInfo.blockSpacing
        let moveDuration: TimeInterval = 0.3
        
        let moveAction = SKAction.moveBy(x: 0, y: -shiftDistance, duration: moveDuration)
        
        let dispatchGroup = DispatchGroup()
        
        for block in gameScene.blocks {
            dispatchGroup.enter()
            block.run(moveAction) {
                dispatchGroup.leave()
            }
        }
        for bonusBall in gameScene.bonusBalls {
            bonusBall.run(moveAction)
        }
        for powerUp in gameScene.powerUpsOnBoard {
            powerUp.run(moveAction)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func addNewBlockRow(completion: @escaping () -> ()) {
        let blockSize = gameScene.layoutInfo.blockSize
        let columns = gameScene.layoutInfo.columns
        let playAreaTop = gameScene.layoutInfo.playAreaPos.y + (gameScene.layoutInfo.playAreaSize.height / 2)
        let topSpaceOffset = (blockSize.height + 10) * 1.5
        let topY = playAreaTop - topSpaceOffset
        
        let currentRound = gameScene.gameInfo?.round ?? 1
        
        let blockCountWeights = [1, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 6, 6, 7]
        let numberOfBlocks = blockCountWeights.randomElement() ?? 4
        
        var availableColumns = Array(0..<columns)
        availableColumns.shuffle()
        
        let doubleBlockCount: Int
        let random = Double.random(in: 0...1)
        if random < 0.1 && numberOfBlocks >= 3 {
            doubleBlockCount = 3
        } else if random < 0.3 && numberOfBlocks >= 2 {
            doubleBlockCount = 2
        } else if random < 0.5 && numberOfBlocks >= 1 {
            doubleBlockCount = 1
        } else {
            doubleBlockCount = 0
        }
        
        var doubleBlockIndices = Array(0..<numberOfBlocks).shuffled().prefix(doubleBlockCount)
        
        
        var emptyColumns = availableColumns
        
        let dispatchGroup = DispatchGroup()

        for i in 0..<numberOfBlocks {
            let col = availableColumns[i]
            
            emptyColumns.removeAll { $0 == col }
            
            let x = CGFloat(col) * (blockSize.width + gameScene.layoutInfo.blockSpacing) + blockSize.width / 2 + gameScene.layoutInfo.blockSpacing
            let y = topY
            
            var hitPoints = currentRound
            
            if doubleBlockIndices.contains(i) {
                hitPoints = currentRound * 2
            }
            
            let blockNode = BlockNode(size: blockSize, hitPoints: hitPoints)
            
            blockNode.position = CGPoint(x: x, y: y + gameScene.size.height)
            gameScene.addChild(blockNode)
            gameScene.blocks.append(blockNode)
            
            let dropAction = SKAction.moveTo(y: y, duration: 0.2)
            let bounceAction = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 8, duration: 0.1),
                SKAction.moveBy(x: 0, y: -8, duration: 0.1)
            ])
            let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
            
            let animationSequence = SKAction.sequence([
                SKAction.group([dropAction, fadeInAction]),
                bounceAction
            ])
            
            dispatchGroup.enter()
            blockNode.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.1),
                animationSequence
            ])) {
                dispatchGroup.leave()
            }
        }
        
        if !emptyColumns.isEmpty && Double.random(in: 0...1) < 1.0 {
            dispatchGroup.enter()

            let randomEmptyColumn = emptyColumns.randomElement()!
            let x = CGFloat(randomEmptyColumn) * (blockSize.width + gameScene.layoutInfo.blockSpacing) + gameScene.layoutInfo.blockSpacing + (blockSize.width / 2)
            let y = topY
            gameScene.addBonusBall(at: CGPoint(x: x, y: y))
            emptyColumns.removeAll { $0 == randomEmptyColumn }
            
            dispatchGroup.leave()
        }
        
        if !emptyColumns.isEmpty && Double.random(in: 0...1) < 1.0 {
            dispatchGroup.enter()

            let randomEmptyColumn = emptyColumns.randomElement()!
            let x = CGFloat(randomEmptyColumn) * (blockSize.width + gameScene.layoutInfo.blockSpacing) + gameScene.layoutInfo.blockSpacing + (blockSize.width / 2)
            let y = topY
            gameScene.addPowerUp(at: CGPoint(x: x, y: y))
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
