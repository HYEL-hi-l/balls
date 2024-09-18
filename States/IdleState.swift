//
//  IdleState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class IdleState: GameState {
    private let aimingThreshold: CGFloat = 75.0
    private var isAiming = false

    override func didEnter(from previousState: GKState?) {
        print("IdleState")
        
        gameScene.cancelAiming()
        gameScene.enableAiming()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is ShootingState.Type
    }
    
    override func willExit(to nextState: GKState) {
        gameScene.disableAiming()
    }
    
    func handleTouchesBegan(_ touchLocation: CGPoint) {
        if distanceToShooter(touchLocation) < aimingThreshold {
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
            if distanceToShooter(touchLocation) >= aimingThreshold {
                stateMachine?.enter(ShootingState.self)
            } else {
                gameScene.cancelAiming()
            }
            isAiming = false
        }
    }
    
    private func distanceToShooter(_ point: CGPoint) -> CGFloat {
        let shooterPosition = gameScene.shooter.position
        return hypot(point.x - shooterPosition.x, point.y - shooterPosition.y)
    }
}
