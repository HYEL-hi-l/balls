//
//  FastForwardNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class FSFastForwardNode: SKSpriteNode {
    
    var ballSpeedMultiplier: CGFloat = 1.0
    weak var gameScene: FSGameScene?
    var showTimer: Timer?
    var isTappable: Bool = false
    
    init(scene: FSGameScene) {
        self.gameScene = scene
        
        let texture = SKTexture(imageNamed: "fast_forward")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = 20
        self.alpha = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}


// MARK: Helpers
extension FSFastForwardNode {
    
    func scheduleShow(in duration: TimeInterval) {
        showTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.show()
        }
    }
    
    func show() {
        self.alpha = 0.3
        self.isTappable = true
    }
    
    func cancelShow() {
        hide()
        showTimer?.invalidate()
        showTimer = nil
    }
    
    func hide() {
        self.alpha = 0.0
        self.isTappable = false
    }
    
}


// MARK: Speed Control
extension FSFastForwardNode {
    
    func toggleBallSpeed() {
        guard isTappable else { return }
        
        hide()
        
        if ballSpeedMultiplier == 1.0 {
            updateBallSpeed(to: 1.8)
            scheduleShow(in: 10.0)
        } else if ballSpeedMultiplier == 1.8 {
            updateBallSpeed(to: 1.5)
        }
    }
    
    private func updateBallSpeed(to multiplier: CGFloat) {
        ballSpeedMultiplier = multiplier
        gameScene?.updateBallSpeeds(multiplier: ballSpeedMultiplier)
    }
    
    func resetSpeed() {
        ballSpeedMultiplier = 1.0
        gameScene?.updateBallSpeeds(multiplier: ballSpeedMultiplier)
        hide()
    }
    
}
