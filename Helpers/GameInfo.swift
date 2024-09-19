//
//  GameInfo.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import Foundation

class GameInfo {
    var score: Int
    var round: Int
    var ballCount: Int
    var ballSpeed: CGFloat
    var ballSpeedMultiplier: CGFloat
    
    init() {
        score = 0
        round = 1
        ballCount = 1
        ballSpeed = 8
        ballSpeedMultiplier = 1
    }
    
    func reset() {
        score = 0
        round = 1
        ballCount = 1
        ballSpeed = 8
        ballSpeedMultiplier = 1
    }
    
    func incrementScore(by amount: Int) {
        score = score + amount
    }

    func incrementRound() {
        round = round + 1
    }

    func incrementBallCount(by amount: Int) {
        ballCount = ballCount + amount
    }
}
