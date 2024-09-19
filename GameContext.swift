//
//  Untitled.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SwiftUI

class GameContext {

    private(set) var scene: GameScene!
    private(set) var stateMachine: GKStateMachine?

    var layoutInfo: LayoutInfo
    var gameInfo: GameInfo

    init() {
        self.layoutInfo = LayoutInfo(screenSize: .zero)
        self.gameInfo = GameInfo()
        
        self.scene = GameScene(context: self, size: UIScreen.main.bounds.size)
        
        configureStates()
        configureLayoutInfo()
    }

    func configureStates() {
        stateMachine = GKStateMachine(
            states: [
                StartState(gameScene: scene),
                IdleState(gameScene: scene),
                ShootingState(gameScene: scene),
                ResolveShotState(gameScene: scene),
                GameOverState(gameScene: scene)
            ]
        )
    }
    
    func configureLayoutInfo() {
        let screenSize = UIScreen.main.bounds.size
        
        layoutInfo.screenSize = screenSize
        
        layoutInfo.playAreaOffset = screenSize.height * 0.01
        layoutInfo.playAreaSize = CGSize(width: screenSize.width, height: screenSize.height * 0.6)
        layoutInfo.playAreaPos = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + layoutInfo.playAreaOffset)
        
        layoutInfo.shooterSize = CGSize(width: 40, height: 40)
        layoutInfo.shooterPos = CGPoint(x: screenSize.width / 2, y: layoutInfo.playAreaPos.y - layoutInfo.playAreaSize.height / 2 + 30)
        
        let combinedPowerUpSlotsLength = layoutInfo.playAreaSize.width - (4 * layoutInfo.powerUpSlotSpacing) - layoutInfo.powerUpSlotSpacing
        let powerUpSlotLength = combinedPowerUpSlotsLength / Double(4)
        layoutInfo.powerUpSlotSize = CGSize(width: powerUpSlotLength, height: powerUpSlotLength)
        let sectionUnderPlayArea = layoutInfo.screenSize.height / 2 - layoutInfo.playAreaSize.height / 2
        layoutInfo.powerUpSlotYPos = (sectionUnderPlayArea * 0.58) - (layoutInfo.powerUpSlotSize.height / 2)
        
        let ffX = layoutInfo.playAreaPos.x + layoutInfo.playAreaSize.width / 2 - layoutInfo.fastForwardPadding
        let ffY = layoutInfo.playAreaPos.y + layoutInfo.playAreaSize.height / 2 - layoutInfo.fastForwardPadding - 12.5
        layoutInfo.fastForwardPos =  CGPoint(x: ffX, y: ffY)
        
        layoutInfo.bottomLineY = layoutInfo.shooterPos.y - layoutInfo.ballRadius * 1.4
        layoutInfo.gameOverLineY = layoutInfo.shooterPos.y
        let combinedBlockEdgeLength = layoutInfo.playAreaSize.width - (CGFloat(layoutInfo.columns + 1) * layoutInfo.blockSpacing)
        let blockEdgeLength = combinedBlockEdgeLength / Double(layoutInfo.columns)
        layoutInfo.blockSize = CGSize(width: blockEdgeLength, height: blockEdgeLength)
    }
}
