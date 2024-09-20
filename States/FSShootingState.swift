//
//  ShootingState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit

class FSShootingState: FSGameState {
    
    private var bottomY: CGFloat = 0
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FSResolveShotState.Type
    }

    override func didEnter(from previousState: GKState?) {
        bottomY = gameScene.shooter.position.y
        shootAllBalls()
        gameScene.fastForwardNode?.scheduleShow(in: 5.0)
    }
    
}


// MARK: Helpers
extension FSShootingState {
    
    private func shootAllBalls() {
        let ballCount = gameScene.gameInfo!.ballCount
        var shotDelay: CGFloat = 0.1
        if ballCount > 500 {
            shotDelay = 50.0 / CGFloat(ballCount)
        }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        for i in 0..<ballCount {
            dispatchGroup.enter()
            let ball = gameScene.createBall()
            let delay = SKAction.wait(forDuration: shotDelay * Double(i))
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
