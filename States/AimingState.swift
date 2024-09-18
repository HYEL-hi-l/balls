//
//  AimingState.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit

class AimingState: GameState {
    override func didEnter(from previousState: GKState?) {
        // Enable aiming mechanic
        // Calculate and display trajectory
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IdleState.Type || stateClass is ShootingState.Type
    }
}
