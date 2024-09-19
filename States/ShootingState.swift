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
        print("ShootingState")
        
        bottomY = gameScene.shooter.position.y
        shootAllBalls()
        gameScene.fastForwardNode?.scheduleShow(in: 5.0)
        gameScene.deactivateLaserSight()
    }
    
}


// MARK: Helpers
extension ShootingState {
    
    private func shootAllBalls() {
        let ballCount = gameScene.gameInfo!.ballCount
        for i in 0..<ballCount {
            let ball = gameScene.createBall()
            let delay = SKAction.wait(forDuration: 0.1 * Double(i))
            let shoot = SKAction.run { [weak self] in
                self?.gameScene.shootBall(ball)
            }
            let sequence = SKAction.sequence([delay, shoot])
            gameScene.run(sequence)
            
            if i == ballCount - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.gameScene.allBallsShot = true
                }
            }
        }
    }
    
}
