//
//  ShootingState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class ShootingState: GameState {
    
    private var bottomY: CGFloat = 0
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is ResolveShotState.Type
    }

    override func didEnter(from previousState: GKState?) {
        bottomY = gameScene.shooter.position.y
        shootAllBalls()
        gameScene.fastForwardNode?.scheduleShow(in: 5.0)
    }
    
}


// MARK: Helpers
extension ShootingState {
    
    private func shootAllBalls() {
        let ballCount = gameScene.gameInfo!.ballCount
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        for i in 0..<ballCount {
            dispatchGroup.enter()
            let ball = gameScene.createBall()
            let delay = SKAction.wait(forDuration: 0.1 * Double(i))
            let shoot = SKAction.run { [weak self] in
                self?.gameScene.shootBall(ball)
            }
            let sequence = SKAction.sequence([delay, shoot])
            gameScene.run(sequence) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main) {
            self.gameScene.shooter.shooterBody.isHidden = true
            self.gameScene.allBallsShot = true
        }
        
    }
    
}
