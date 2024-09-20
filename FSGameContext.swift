//
//  Untitled.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SwiftUI

class FSGameContext {

    private(set) var scene: FSGameScene!
    private(set) var stateMachine: GKStateMachine?

    var layoutInfo: FSLayoutInfo
    var gameInfo: FSGameInfo

    init() {
        self.layoutInfo = FSLayoutInfo(screenSize: .zero)
        self.gameInfo = FSGameInfo()
        
        self.scene = FSGameScene(context: self, size: UIScreen.main.bounds.size)
        
        configureStates()
        configureLayoutInfo()
    }

    func configureStates() {
        stateMachine = GKStateMachine(
            states: [
                FSStartState(gameScene: scene),
                FSIdleState(gameScene: scene),
                FSShootingState(gameScene: scene),
                FSResolveShotState(gameScene: scene),
                FSGameOverState(gameScene: scene)
            ]
        )
    }
    
    func configureLayoutInfo() {
        let screenSize = UIScreen.main.bounds.size
        
        layoutInfo.screenSize = screenSize
        
        let combinedBlockEdgeLength = layoutInfo.screenSize.width - (CGFloat(layoutInfo.columns + 1) * layoutInfo.blockSpacing)
        let blockEdgeLength = combinedBlockEdgeLength / Double(layoutInfo.columns)
        layoutInfo.blockSize = CGSize(width: blockEdgeLength, height: blockEdgeLength)
        layoutInfo.ballRadius = layoutInfo.blockSize.width / 5.22857
        print(layoutInfo.blockSize)
        
        layoutInfo.playAreaOffset = screenSize.height * 0.01
        let playAreaHeight = (layoutInfo.blockSize.height + layoutInfo.blockSpacing) * 9 + layoutInfo.blockSpacing
        layoutInfo.playAreaSize = CGSize(width: screenSize.width, height: playAreaHeight)
        layoutInfo.playAreaPos = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + layoutInfo.playAreaOffset)

        layoutInfo.shooterPos = CGPoint(x: screenSize.width / 2, y: layoutInfo.playAreaPos.y - layoutInfo.playAreaSize.height / 2 + layoutInfo.playAreaSize.height / 12.5)
        
        let combinedPowerUpSlotsLength = layoutInfo.playAreaSize.width - (4 * layoutInfo.powerUpSlotSpacing) - layoutInfo.powerUpSlotSpacing
        let powerUpSlotLength = combinedPowerUpSlotsLength / Double(4)
        layoutInfo.powerUpSlotSize = CGSize(width: powerUpSlotLength, height: powerUpSlotLength)
        let sectionUnderPlayArea = (layoutInfo.screenSize.height / 2 + layoutInfo.playAreaOffset) - layoutInfo.playAreaSize.height / 2
        layoutInfo.powerUpSlotYPos = (sectionUnderPlayArea * 0.5) - (layoutInfo.powerUpSlotSize.height / 2)
        
        let ffX = layoutInfo.playAreaPos.x + layoutInfo.playAreaSize.width / 2 - layoutInfo.fastForwardPadding
        let ffY = layoutInfo.playAreaPos.y + layoutInfo.playAreaSize.height / 2 - (layoutInfo.fastForwardPadding * 1.3)
        layoutInfo.fastForwardPos =  CGPoint(x: ffX, y: ffY)
        
        layoutInfo.bottomLineY = layoutInfo.shooterPos.y - layoutInfo.ballRadius * 1.7
        layoutInfo.gameOverLineY = layoutInfo.bottomLineY
//        layoutInfo.gameOverLineY = layoutInfo.shooterPos.y
        
        let roundCountNodeHeight = layoutInfo.blockSize.height * 1.2
        layoutInfo.roundCountNodeSize =  CGSize(width: roundCountNodeHeight * 2, height: roundCountNodeHeight)
        let playAreaTop = layoutInfo.playAreaPos.y + layoutInfo.playAreaSize.height / 2
        let roundCountNodeY = playAreaTop + (layoutInfo.roundCountNodeSize.height * 0.75)
        layoutInfo.roundCountNodePos =  CGPoint(x: layoutInfo.playAreaPos.x, y: roundCountNodeY)

    }
}
