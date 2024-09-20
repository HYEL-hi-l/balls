//
//  IdleState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class IdleState: GameState {
    
    private var tutorialNode: SKNode?
    private let aimingThreshold: CGFloat = 150.0
    private var isAiming = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is ShootingState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("Idle")

        for slot in gameScene.powerUpSlots {
            slot.dimPowerUp(isDimmed: false)
        }
        
        gameScene.shooter.shooterBody.zRotation = 0
        
        showTutorialAnimation()
        gameScene.cancelAiming()
        gameScene.enableAiming()
    }
    
    override func willExit(to nextState: GKState) {
        for slot in gameScene.powerUpSlots {
            slot.dimPowerUp(isDimmed: true)
        }
        
        gameScene.disableAiming()
    }
    
    override func handleTap(_ touchLocation: CGPoint) {
        tutorialNode?.removeFromParent()
        if isWithinPlayArea(touchLocation) && distanceToShooter(touchLocation) < aimingThreshold {
            isAiming = true
            gameScene.beginAiming()
        }
    }
    
    func handleTouchesMoved(_ touchLocation: CGPoint) {
        if isAiming {
            gameScene.updateAiming(to: touchLocation)
        }
    }
    
    func handleTouchesEnded(_ touchLocation: CGPoint) {

        if isAiming {
            if distanceToShooter(touchLocation) > gameScene.layoutInfo.shooterSize.width / 2 {
                stateMachine?.enter(ShootingState.self)
                gameScene.deactivateLaserSight()
            } else {
                gameScene.cancelAiming()
            }
            isAiming = false
        }
    }
    
}


// MARK: Helpers
extension IdleState {
    
    private func showTutorialAnimation() {
        tutorialNode = SKNode()
        guard let tutorialNode = tutorialNode else { return }
        
        let handTexture = SKTexture(imageNamed: "tutorial_hand")
        let handSprite = SKSpriteNode(texture: handTexture)
        handSprite.position.y = gameScene.shooter.position.y + gameScene.layoutInfo.shooterSize.height
        handSprite.position.x = gameScene.shooter.position.x + handSprite.frame.width / 2
        handSprite.zPosition = 1000
        handSprite.alpha = 0.8
        handSprite.blendMode = .screen
        handSprite.color = .white
        handSprite.colorBlendFactor = 1.0
        
        if gameScene.shooter.position.x > gameScene.layoutInfo.screenSize.width * 0.3 {
            handSprite.xScale = -1
            handSprite.position.x = gameScene.shooter.position.x - handSprite.frame.width / 2
        }
        
        
        tutorialNode.addChild(handSprite)
        gameScene.addChild(tutorialNode)
        
        let moveUp = SKAction.moveBy(x: 0, y: gameScene.layoutInfo.shooterSize.height, duration: 1.25)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 1.25)
        let moveDown = SKAction.moveBy(x: 0, y: -gameScene.layoutInfo.shooterSize.height, duration: 0.3)
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), SKAction.group([moveDown, fadeIn])])
        let repeatForever = SKAction.repeatForever(sequence)
        
        handSprite.run(repeatForever)
    }
    
    private func distanceToShooter(_ point: CGPoint) -> CGFloat {
        let shooterPosition = gameScene.shooter.position
        return hypot(point.x - shooterPosition.x, point.y - shooterPosition.y)
    }
    
    private func isWithinPlayArea(_ point: CGPoint) -> Bool {
        return gameScene.playArea.frame.contains(point)
    }
    
}
