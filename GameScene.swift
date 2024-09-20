//
//  GameScene.swift
//  balls Shared
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

protocol TapHandler {
    func handleTap(_ touchLocation: CGPoint)
}

class GameScene: SKScene {
    
    unowned let context: GameContext
    var gameInfo: GameInfo? { context.gameInfo }
    var layoutInfo: LayoutInfo { context.layoutInfo }
    
    let ballsAtlas = SKTextureAtlas(named: "BallsAtlas")
    let blocksAtlas = SKTextureAtlas(named: "BlocksAtlas")
    
    private var background: BackgroundNode!
    private var bottomLine: SKShapeNode!
    var playArea: PlayAreaNode!
    var shooter: ShooterNode!
    var showRoundNode: RoundCountNode!
    var fastForwardNode: FastForwardNode!
    var ballCountNode: BallCountNode!
    private var topWindow: SKShapeNode!
    private var bottomWindow: SKShapeNode!
    private var noMansLand: SKNode!

    var balls: [BallNode] = []
    var activeBalls: [BallNode] = []
    var blocks: [BlockNode] = []
    var bonusBalls: [BonusBallNode] = []
    var isAimingEnabled: Bool = false
    var allBallsShot: Bool = false
    
    var powerUpIsActive: Bool = false
    var activePowerUpSlot: PowerUpSlotNode?
    var powerUpSlots: [PowerUpSlotNode] = []
    var collectedPowerUps: [PowerUpNode?] = [nil, nil, nil, nil]
    var powerUpsOnBoard: [PowerUpNode] = []
    var isLaserSightActive: Bool = false
    var isDestructiveTouchActive: Bool = false
    var isDoubleDamageActive: Bool = false
    var remainingBalls: Int = 1
    var firstBallToHitBottom: BallNode?
    
    private let minVerticalVelocity: CGFloat = 15
    private let stuckThreshold: CGFloat = 15
    private let stuckTimeThreshold: TimeInterval = 10.0

    
    init(context: GameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        setupPlayArea()
        setupShooter()
        setupBottomLine()
        setupRoundCountNode()
        setupFastForwardNode()
        setupPowerUpSlots()
        setupBallCountNode()
        setupWindows()
        setupNoMansLand()
        
        ballsAtlas.preload {
            self.context.stateMachine?.enter(StartState.self)
        }
        blocksAtlas.preload {
            self.createBlockEmitter(at: CGPoint(x: -self.layoutInfo.screenSize.width, y: -self.layoutInfo.screenSize.height), texture: self.blocksAtlas.textureNamed("happy"), size: self.layoutInfo.blockSize, color: .white)
        }

    }
    
    func reset() {
        showRoundNode.reset()
        gameInfo?.reset()
        shooter.position = layoutInfo.shooterPos
        shooter.shooterBody.zRotation = 0
        shooter.reset()
        shooter.shooterBody.isHidden = false
        
        clearBlocks()
        clearActiveBalls()
        clearAllBalls()
        clearBonusBalls()
        clearPowerUps()

        remainingBalls = gameInfo?.ballCount ?? 1
        updateBallCountDisplay()
        updateBallCountNodePosition()
        firstBallToHitBottom = nil
    }
    
}


// MARK: Setup
extension GameScene {
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
    }
    
    func setupBackground() {
        background = BackgroundNode()
        background.setup(screenSize: size)
        addChild(background)
    }
    
    func setupPlayArea() {
        playArea = PlayAreaNode(size: layoutInfo.playAreaSize, position: layoutInfo.playAreaPos)
        addChild(playArea)
    }
    
    func setupShooter() {
        shooter = ShooterNode(size: layoutInfo.shooterSize, ballRadius: layoutInfo.ballRadius)
        shooter.position = layoutInfo.shooterPos
        shooter.zPosition = 2
        addChild(shooter)
    }
    
    func setupBottomLine() {
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: 0, y: layoutInfo.bottomLineY))
        linePath.addLine(to: CGPoint(x: size.width, y: layoutInfo.bottomLineY))
        
        bottomLine = SKShapeNode(path: linePath)
        bottomLine.strokeColor = .darkGray
        bottomLine.lineWidth = 1
        bottomLine.zPosition = 1
        
        bottomLine.physicsBody = SKPhysicsBody(edgeChainFrom: linePath)
        bottomLine.physicsBody?.isDynamic = false
        bottomLine.physicsBody?.categoryBitMask = PhysicsCategory.BottomLine
        bottomLine.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        bottomLine.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        
        addChild(bottomLine)
    }
    func setupRoundCountNode() {
        showRoundNode = RoundCountNode(size: layoutInfo.RoundCountNodeSize)
        showRoundNode.position = layoutInfo.RoundCountNodePos
        addChild(showRoundNode)
    }
    
    func setupFastForwardNode() {
        fastForwardNode = FastForwardNode(scene: self)
        fastForwardNode.position = layoutInfo.fastForwardPos
        addChild(fastForwardNode)
    }
    
    func setupPowerUpSlots() {
        let slotSize = layoutInfo.powerUpSlotSize
        let spacing = layoutInfo.powerUpSlotSpacing
        let totalWidth = (slotSize.width * 4) + (spacing * 4)
        let startX = -(totalWidth / 2 - size.width / 2) + slotSize.width / 2 + spacing / 2
        let bottomY = layoutInfo.powerUpSlotYPos
        
        for i in 0..<4 {
            let slot = PowerUpSlotNode(size: slotSize)
            slot.position = CGPoint(x: startX + (CGFloat(i) * (slotSize.width + spacing)), y: CGFloat(bottomY) + slotSize.height / 2)
            slot.zPosition = 1
            addChild(slot)
            powerUpSlots.append(slot)
        }
    }

    
    func setupBallCountNode() {
        ballCountNode = BallCountNode()
        ballCountNode.position = CGPoint(x: shooter.position.x + layoutInfo.shooterSize.width * 0.6, y: shooter.position.y + layoutInfo.shooterSize.width * 0.6)
        ballCountNode.zPosition = 3
        addChild(ballCountNode)
        updateBallCountDisplay()
    }
    
    func setupWindows() {
        let topWindowHeight: CGFloat = layoutInfo.screenSize.height - (layoutInfo.playAreaPos.y + layoutInfo.playAreaSize.height / 2)
        let bottomWindowHeight: CGFloat = layoutInfo.screenSize.height - (layoutInfo.playAreaPos.y + layoutInfo.playAreaSize.height / 2)
        let fillColor: UIColor = .white.withAlphaComponent(0.1)
        let strokeColor: UIColor = .white
        let lineWidth: CGFloat = 3
        
        topWindow = SKShapeNode(rect: CGRect(x: layoutInfo.playAreaPos.x - layoutInfo.playAreaSize.width / 2 - lineWidth, y: layoutInfo.playAreaPos.y + layoutInfo.playAreaSize.height / 2, width: layoutInfo.playAreaSize.width + lineWidth * 2, height: topWindowHeight + lineWidth))
        topWindow.fillColor = fillColor
        topWindow.strokeColor = strokeColor
        topWindow.lineWidth = lineWidth
        topWindow.zPosition = 0
        addChild(topWindow)
        
        bottomWindow = SKShapeNode(rect: CGRect(x: layoutInfo.playAreaPos.x - layoutInfo.playAreaSize.width / 2 - lineWidth, y: 0, width: layoutInfo.playAreaSize.width + lineWidth * 2, height: bottomWindowHeight + lineWidth))
        bottomWindow.fillColor = fillColor
        bottomWindow.strokeColor = strokeColor
        bottomWindow.lineWidth = lineWidth
        bottomWindow.zPosition = 0
        addChild(bottomWindow)
    }

    
    private func setupNoMansLand() {
        noMansLand = SKNode()
        
        let barrierThickness: CGFloat = 400
        
        let topBarrier = SKShapeNode(rectOf: CGSize(width: size.width + 2 * barrierThickness, height: barrierThickness))
        let leftBarrier = SKShapeNode(rectOf: CGSize(width: barrierThickness, height: size.height + 2 * barrierThickness))
        let rightBarrier = SKShapeNode(rectOf: CGSize(width: barrierThickness, height: size.height + 2 * barrierThickness))
        let bottomBarrier = SKShapeNode(rectOf: CGSize(width: size.width + 2 * barrierThickness, height: barrierThickness))
        let offset = barrierThickness / 10
        
        topBarrier.position = CGPoint(x: size.width / 2, y: size.height + barrierThickness / 2 + offset)
        leftBarrier.position = CGPoint(x: -barrierThickness / 2 - offset, y: size.height / 2)
        rightBarrier.position = CGPoint(x: size.width + barrierThickness / 2 + offset, y: size.height / 2)
        bottomBarrier.position = CGPoint(x: size.width / 2, y: -barrierThickness / 2 - offset)
        
        let barrierPhysicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -barrierThickness, y: -barrierThickness, width: size.width + 2 * barrierThickness, height: size.height + 2 * barrierThickness))
        barrierPhysicsBody.isDynamic = false
        barrierPhysicsBody.categoryBitMask = PhysicsCategory.NoMansLand
        barrierPhysicsBody.contactTestBitMask = PhysicsCategory.Ball
        barrierPhysicsBody.collisionBitMask = PhysicsCategory.None
        
        noMansLand.physicsBody = barrierPhysicsBody
        
        noMansLand.addChild(topBarrier)
        noMansLand.addChild(leftBarrier)
        noMansLand.addChild(rightBarrier)
        noMansLand.addChild(bottomBarrier)
        
        noMansLand.alpha = 1.0
        
        addChild(noMansLand)
    }
    
}


// MARK: Touch
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else { print("failtouchesbegan"); return }
        let location = touch.location(in: self)
        
        if fastForwardNode.contains(location) && fastForwardNode.isTappable && !isDestructiveTouchActive {
            fastForwardNode.toggleBallSpeed()
        }
    
        if isDestructiveTouchActive {
            handleDestructiveTouch(at: location)
        } else if !powerUpIsActive, !playArea.frame.contains(location), let _ = context.stateMachine?.currentState as? IdleState {
            handlePowerUpSlotTap(at: location)
        } else if let currentState = context.stateMachine?.currentState as? TapHandler {
            currentState.handleTap(location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let state = context.stateMachine?.currentState as? IdleState else {
            return
        }
        let location = touch.location(in: self)
        if !isDestructiveTouchActive {
            state.handleTouchesMoved(location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let state = context.stateMachine?.currentState as? IdleState else {
            print("touchesEnded: state machine not idle")
            return
        }
        let location = touch.location(in: self)
        if !isDestructiveTouchActive {
            state.handleTouchesEnded(location)
        }
    }
    
    private func handlePowerUpSlotTap(at location: CGPoint) {
        for slot in powerUpSlots {
            if slot.contains(location), let powerUp = slot.powerUp {
                if powerUp.type == .destructiveTouch {
                    if !blocks.isEmpty {
                        activePowerUpSlot = slot
                        activatePowerUp(powerUp)
                        slot.activate()
                    }
                } else {
                    activePowerUpSlot = slot
                    activatePowerUp(powerUp)
                    slot.activate()
                }
                break
            }
        }
    }
    
    private func handleDestructiveTouch(at location: CGPoint) {
        if let tappedNode = atPoint(location) as? BlockNode {
            removeBlock(tappedNode)
            gameInfo?.incrementScore(by: tappedNode.hitPoints)
            deactivateDestructiveTouch()
        }
    }
}


// MARK: Updating and checks
extension GameScene {
    
    override func update(_ currentTime: TimeInterval) {
        context.stateMachine?.update(deltaTime: currentTime)

        if isLaserSightActive {
            shooter.update(currentTime)
        }
        
        handleStuckBalls(currentTime)
    }
    
    private func handleStuckBalls(_ currentTime: TimeInterval) {
        for ball in activeBalls {
            if abs(ball.physicsBody?.velocity.dy ?? 0) < minVerticalVelocity {
                if ball.stuckStartTime == nil {
                    ball.stuckStartTime = currentTime
                    ball.stuckPosition = ball.position
                } else if currentTime - ball.stuckStartTime! > stuckTimeThreshold {
                    let impulse = CGVector(dx: 0, dy: ball.physicsBody?.velocity.dy ?? 0 <= 0 ? 5 : -5)
                    ball.physicsBody?.applyImpulse(impulse)
                    ball.stuckStartTime = nil
                    ball.stuckPosition = nil
                }
            } else if let stuckPosition = ball.stuckPosition {
                if ball.position.distance(to: stuckPosition) > stuckThreshold {
                    ball.stuckStartTime = nil
                    ball.stuckPosition = nil
                }
            } else {
                ball.stuckStartTime = nil
                ball.stuckPosition = nil
            }
        }
    }
    
}


// MARK: Ball logic
extension GameScene {
    func createBall() -> BallNode {
        let ball = BallNode(type: .normal, radius: layoutInfo.ballRadius, atlas: ballsAtlas)
        ball.position = shooter.position
        balls.append(ball)
        addChild(ball)
        return ball
    }
    
    func shootBall(_ ball: BallNode) {
        shooter.shoot(ball)
        activeBalls.append(ball)
        let velocity = ball.physicsBody?.velocity
        let multiplier = gameInfo?.ballSpeedMultiplier ?? 1
        let newVelocity = CGVector(dx: (velocity?.dx ?? 0) * multiplier, dy: (velocity?.dy ?? 0) * multiplier)
        ball.physicsBody?.velocity = newVelocity
        remainingBalls -= 1
        updateBallCountDisplay()
    }
    
    func clearAllBalls() {
        for ball in balls {
            ball.removeFromParent()
        }
        balls.removeAll()
    }
    
    func clearActiveBalls() {
        for ball in activeBalls {
            ball.removeFromParent()
        }
        activeBalls.removeAll()
    }
    
    func updateBallSpeeds(multiplier: CGFloat) {
        gameInfo?.ballSpeedMultiplier *= multiplier
        for ball in activeBalls {
            let velocity = ball.physicsBody?.velocity
            let newVelocity = CGVector(dx: (velocity?.dx ?? 0) * multiplier, dy: (velocity?.dy ?? 0) * multiplier)
            ball.physicsBody?.velocity = newVelocity
        }
    }
    
    func updateBallCountDisplay() {
        ballCountNode.updateCount(remainingBalls)
    }

    func updateBallCountNodePosition() {
        if shooter.position.x >= layoutInfo.screenSize.width * 0.8 {
            ballCountNode.position.x = shooter.position.x - layoutInfo.shooterSize.width * 0.6
        } else {
            ballCountNode.position.x = shooter.position.x + layoutInfo.shooterSize.width * 0.6
        }
    }
        
    func addBonusBall(at position: CGPoint) {
        let bonusBall = BonusBallNode(position: position, radius: layoutInfo.blockSize.width * 0.3, atlas: ballsAtlas)
        bonusBalls.append(bonusBall)
        addChild(bonusBall)
        animateExtraItem(bonusBall, at: position)
    }
    
    func animateExtraItem(_ node: SKNode, at position: CGPoint) {
        node.position = CGPoint(x: position.x, y: position.y + size.height)
        node.alpha = 0
        
        let dropAction = SKAction.moveTo(y: position.y, duration: 0.2)
        let bounceAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 4, duration: 0.1),
            SKAction.moveBy(x: 0, y: -4, duration: 0.1)
        ])
        let fadeInAction = SKAction.fadeIn(withDuration: 0.2)
        
        let animationSequence = SKAction.sequence([
            SKAction.group([dropAction, fadeInAction]),
            bounceAction
        ])
        
        node.run(SKAction.sequence([
            animationSequence
        ]))
    }
    
    func clearBonusBalls() {
        for bonusBall in bonusBalls {
            bonusBall.removeFromParent()
        }
        bonusBalls.removeAll()
    }
}


// MARK: Aiming logic
extension GameScene {
    
    func beginAiming() {
        shooter.showAimLine()
        if isLaserSightActive {
            shooter.showLaserSight()
        }
        shooter.shooterBody.texture = SKTexture(imageNamed: "raspberry_shooting")
    }
    
    func updateAiming(to point: CGPoint) {
        shooter.aim(toward: point)
    }
    
    func enableAiming() {
        isAimingEnabled = true
    }
    
    func disableAiming() {
        isAimingEnabled = false
        shooter.shooterBody.texture = SKTexture(imageNamed: "raspberry")
        shooter.hideAimLine()
    }
    
    func cancelAiming() {
        shooter.hideAimLine()
        shooter.hideLaserSight()
        shooter.shooterBody.texture = SKTexture(imageNamed: "raspberry")
    }
}


// MARK: Block Llgic
extension GameScene {
    func addBlock(_ block: BlockNode) {
        blocks.append(block)
        addChild(block)
    }
    
    func removeBlock(_ block: BlockNode) {
        if let index = blocks.firstIndex(of: block) {
            blocks.remove(at: index)
        }
        block.removeFromParent()
        gameInfo?.incrementScore(by: 1)
        createBlockEmitter(at: block.position, texture: blocksAtlas.textureNamed("CC_Happy"), size: layoutInfo.blockSize, color: block.fillColor)

    }
    
    func clearBlocks() {
        for block in blocks {
            block.removeFromParent()
        }
        blocks.removeAll()
    }
    
    private func createBlockEmitter(at position: CGPoint, texture: SKTexture, size: CGSize, color: UIColor) {
        guard let emitter = SKEmitterNode(fileNamed: "BlockExplosionEmitter") else { return }
        emitter.position = position
        emitter.particleTexture = texture
        emitter.particleColor = color
        emitter.zPosition = 1
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        
        addChild(emitter)
        
        let wait = SKAction.wait(forDuration: emitter.particleLifetime + emitter.particleLifetimeRange)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
}


// MARK: PowerUps
extension GameScene {
    func addPowerUp(at position: CGPoint) {
        let powerUpSize = CGSize(width: layoutInfo.blockSize.width * 0.8, height: layoutInfo.blockSize.height * 0.8)
//        let powerUpType: PowerUpNode.PowerUpType = [.laserSight, .destructiveTouch, .doubleDamage].randomElement()!
        let powerUpType: PowerUpNode.PowerUpType = [.doubleDamage, .doubleDamage, .doubleDamage].randomElement()!
        let powerUp = PowerUpNode(type: powerUpType, size: powerUpSize)
        powerUp.position = position
        powerUpsOnBoard.append(powerUp)
        addChild(powerUp)
        animateExtraItem(powerUp, at: position)
    }
    
    func collectPowerUp(_ powerUp: PowerUpNode) {
        guard !powerUp.isCollected else { return }
        
        powerUp.collect()
        if let index = powerUpsOnBoard.firstIndex(of: powerUp) {
            powerUpsOnBoard.remove(at: index)
        }
        
        if let emptySlotIndex = collectedPowerUps.firstIndex(of: nil) {
            collectedPowerUps[emptySlotIndex] = powerUp
            updatePowerUpSlots()
        }
    }
    
    func updatePowerUpSlots() {
        for (index, powerUp) in collectedPowerUps.enumerated() {
            powerUpSlots[index].powerUp = powerUp
            powerUpSlots[index].dimPowerUp(isDimmed: true)
        }
    }
    
    func activatePowerUp(_ powerUp: PowerUpNode) {
        powerUpIsActive = true
        
        for slot in powerUpSlots {
            if slot.powerUp != nil && slot.powerUp != powerUp {
                slot.dimPowerUp(isDimmed: true)
            }
        }

        switch powerUp.type {
        case .laserSight:
            activateLaserSight()
        case .destructiveTouch:
            activateDestructiveTouch()
        case .doubleDamage:
            activateDoubleDamage()
        }
    }
    
    func deactivateActivePowerUp() {
        guard let activePowerUpSlot = activePowerUpSlot else { return }
        
        if let index = powerUpSlots.firstIndex(of: activePowerUpSlot) {
            collectedPowerUps[index] = nil
            _ = activePowerUpSlot.removePowerUp()
        }
        
        powerUpIsActive = false
        self.activePowerUpSlot = nil
        updatePowerUpSlots()
        
        if let _ = context.stateMachine?.currentState as? IdleState {
            for slot in powerUpSlots {
                if slot.powerUp != nil {
                    slot.dimPowerUp(isDimmed: false)
                }
            }
        }
    }
    
    func activateLaserSight() {
        isLaserSightActive = true
    }
    
    func deactivateLaserSight() {
        if powerUpIsActive {
            isLaserSightActive = false
            deactivateActivePowerUp()
            shooter.hideLaserSight()
        }
    }
    
    func activateDestructiveTouch() {
        guard !self.blocks.isEmpty else { return }
        
        isDestructiveTouchActive = true
        shooter.alpha = 0.5
        for block in self.blocks {
            let scaleUp = SKAction.scale(to: 0.9, duration: 0.5)
            let scaleDown = SKAction.scale(to: 1.05, duration: 0.5)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            let repeatScale = SKAction.repeatForever(scaleSequence)
            block.run(repeatScale, withKey: "DestructiveTouchScale")
        }
        
        if !self.bonusBalls.isEmpty {
            for bonusBall in self.bonusBalls {
                bonusBall.alpha = 0.5
                bonusBall.pauseAnimation()
            }
        }
        if !self.powerUpsOnBoard.isEmpty {
            for powerUp in self.powerUpsOnBoard {
                powerUp.alpha = 0.5
                powerUp.pauseAnimation()
            }
        }
        
    }

    func deactivateDestructiveTouch() {
        for block in self.blocks {
            block.removeAction(forKey: "DestructiveTouchScale")
            block.setScale(1.0)
        }
        if !self.bonusBalls.isEmpty {
            for bonusBall in self.bonusBalls {
                bonusBall.alpha = 1.0
                bonusBall.resumeAnimation()
            }
        }
        if !self.powerUpsOnBoard.isEmpty {
            for powerUp in self.powerUpsOnBoard {
                powerUp.alpha = 1.0
                powerUp.resumeAnimation()
            }
        }
        isDestructiveTouchActive = false
        deactivateActivePowerUp()
        shooter.alpha = 1.0
    }
    
    func activateDoubleDamage() {
        shooter.showThunder()
        isDoubleDamageActive = true
    }
    
    func deactivateDoubleDamage() {
        shooter.hideThunder()
        isDoubleDamageActive = false
        deactivateActivePowerUp()
    }
    
    func clearPowerUps() {
        for powerUp in powerUpsOnBoard {
            powerUp.removeFromParent()
        }
        powerUpsOnBoard.removeAll()

        for (index, _) in collectedPowerUps.enumerated() {
            collectedPowerUps[index] = nil
        }
        
        for powerUpSlot in self.powerUpSlots {
            _ = powerUpSlot.removePowerUp()
        }
        
        updatePowerUpSlots()

        isLaserSightActive = false
        isDestructiveTouchActive = false
        powerUpIsActive = false
        activePowerUpSlot = nil
     }
    
}


// MARK: Contact logic
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        case PhysicsCategory.Ball | PhysicsCategory.NoMansLand:
            handleBallNoMansLandCollision(contact)
        case PhysicsCategory.Ball | PhysicsCategory.BottomLine:
            handleBallBottomLineCollision(contact)
        case PhysicsCategory.Ball | PhysicsCategory.Block:
            handleBallBlockCollision(contact)
        case PhysicsCategory.Ball | PhysicsCategory.BonusBall:
            handleBallBonusBallCollision(contact)
        case PhysicsCategory.Ball | PhysicsCategory.PowerUp:
            handleBallPowerUpCollision(contact)
        default:
            break
        }
    }
    
    func handleBallBlockCollision(_ contact: SKPhysicsContact) {
        guard let blockNode = (contact.bodyA.categoryBitMask == PhysicsCategory.Block ? contact.bodyA.node : contact.bodyB.node) as? BlockNode else {
            print("Warning: Expected a BlockNode in collision, but found something else.")
            return
        }

        blockNode.hit(isDoubleDamageActive)
        
        if blockNode.hitPoints <= 0 {
            removeBlock(blockNode)
        }
    }
    
    func handleBallBonusBallCollision(_ contact: SKPhysicsContact) {
        guard let bonusBall = (contact.bodyA.categoryBitMask == PhysicsCategory.BonusBall ? contact.bodyA.node : contact.bodyB.node) as? BonusBallNode else {
            print("Warning: Expected a BonusBallNode in collision, but found something else.")
            return
        }
        
        if !bonusBall.isCollected {
            bonusBall.collect()
            bonusBall.isCollected = true
            if let index = bonusBalls.firstIndex(of: bonusBall) {
                bonusBalls.remove(at: index)
            }
            
            gameInfo?.incrementBallCount(by: 1)
        }
    }

    func handleBallPowerUpCollision(_ contact: SKPhysicsContact) {
        guard let powerUp = (contact.bodyA.categoryBitMask == PhysicsCategory.PowerUp ? contact.bodyA.node : contact.bodyB.node) as? PowerUpNode else {
            print("Warning: Expected a PowerUpNode in collision, but found something else.")
            return
        }
        collectPowerUp(powerUp)
     }
    
    func handleBallBottomLineCollision(_ contact: SKPhysicsContact) {
            guard let ball = (contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node) as? BallNode else {
                print("Warning: Expected a BallNode in collision, but found something else.")
                return
            }
        
        guard activeBalls.contains(ball) else { return }

            if firstBallToHitBottom == nil {
                firstBallToHitBottom = ball
            }
                    
            ball.physicsBody?.isDynamic = false
            ball.physicsBody?.velocity = .zero
        
            if let index = activeBalls.firstIndex(of: ball) {
                activeBalls.remove(at: index)
            }
            
            updateBallPosition(ball)
        }

    func handleBallNoMansLandCollision(_ contact: SKPhysicsContact) {
        guard let ball = (contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node) as? BallNode else {
         print("Warning: Expected a BallNode in collision with barrier, but found something else.")
         return
        }
        
        print("RETURNING BALL FROM NO MANS LAND")
        
        ball.physicsBody?.isDynamic = false
        ball.physicsBody?.velocity = .zero
        ball.position = CGPoint(x: shooter.position.x, y: layoutInfo.bottomLineY)
        
        if let index = activeBalls.firstIndex(of: ball) {
            activeBalls.remove(at: index)
        }
        checkForRoundEnd()
     }
    
    private func updateBallPosition(_ ball: BallNode) {
            let finalYPosition = layoutInfo.bottomLineY
            let animationDuration: TimeInterval = 0.1
            
            let moveAction = SKAction.move(to: CGPoint(x: firstBallToHitBottom?.position.x ?? ball.position.x, y: finalYPosition), duration: animationDuration)
            let fadeAction = SKAction.fadeAlpha(to: 0.5, duration: animationDuration)
            let scaleAction = SKAction.scale(to: 1.2, duration: animationDuration/2)
            let scaleBackAction = SKAction.scale(to: 1.0, duration: animationDuration/2)
            let sequenceAction = SKAction.sequence([
                SKAction.group([moveAction, fadeAction, scaleAction]),
                scaleBackAction
            ])
            
            ball.run(sequenceAction) {
                ball.physicsBody?.isDynamic = false
                ball.physicsBody?.velocity = .zero
                self.checkForRoundEnd()
            }
        }

    func checkForRoundEnd() {
        if activeBalls.isEmpty && allBallsShot == true {
            allBallsShot = false
            context.stateMachine?.enter(ResolveShotState.self)
        }
    }
}

/// used in self.deactivatePowerUp()
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
