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
    
    private var background: BackgroundNode!
    private var bottomLine: SKShapeNode!
    var playArea: PlayAreaNode!
    var shooter: ShooterNode!
    var gameStats: GameStatsNode!
    var fastForwardNode: FastForwardNode!

    private var balls: [BallNode] = []
    var activeBalls: [BallNode] = []
    var blocks: [BlockNode] = []
    var isAimingEnabled: Bool = false
    var allBallsShot: Bool = false
    
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
        setupGameStats()
        setupFastForwardNode()
        context.stateMachine?.enter(StartState.self)
    }
    
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
        shooter = ShooterNode(size: layoutInfo.shooterSize)
        shooter.position = CGPoint(x: self.size.width / 2, y: playArea.frame.minY + 30)
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
        
        addChild(bottomLine)
    }
    
    func setupGameStats() {
        gameStats = GameStatsNode(size: self.size)
        addChild(gameStats)
    }
    
    func setupFastForwardNode() {
        fastForwardNode = FastForwardNode(scene: self)
        fastForwardNode.position = layoutInfo.fastForwardPos
        addChild(fastForwardNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        context.stateMachine?.update(deltaTime: currentTime)
        
        checkBallPositions()
        if allBallsShot {
            checkForRoundEnd()
        }
    }
    
    private func checkBallPositions() {
        let bottomY = shooter.position.y
        for ball in activeBalls {
            if ball.position.y <= bottomY && ball.physicsBody?.velocity.dy ?? 0 < 0 {
                ball.physicsBody?.velocity = .zero
                ball.position.y = bottomY
            }
        }
    }
    
    private func checkForRoundEnd() {
        if activeBalls.allSatisfy({ $0.physicsBody?.velocity == .zero }) {
            context.stateMachine?.enter(ResolveShotState.self)
            allBallsShot = false
        }
    }
    
    func clearActiveBalls() {
        for ball in activeBalls {
            ball.removeFromParent()
        }
        activeBalls.removeAll()
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let viewLocation = recognizer.location(in: view)
        let touchLocation = convertPoint(fromView: viewLocation)
        if let currentState = context.stateMachine?.currentState as? TapHandler {
            currentState.handleTap(touchLocation)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if fastForwardNode.contains(location) {
            fastForwardNode.toggleBallSpeed()
        }
        
        if let currentState = context.stateMachine?.currentState as? TapHandler {
            currentState.handleTap(location)
        }
        
        if let idleState = context.stateMachine?.currentState as? IdleState {
            idleState.handleTouchesBegan(location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let state = context.stateMachine?.currentState as? IdleState else {
            return
        }
        let location = touch.location(in: self)
        state.handleTouchesMoved(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let state = context.stateMachine?.currentState as? IdleState else {
            return
        }
        let location = touch.location(in: self)
        state.handleTouchesEnded(location)
    }
    
    func enableAiming() {
        isAimingEnabled = true
    }
    
    func disableAiming() {
        isAimingEnabled = false
    }
    
    func beginAiming() {
        shooter.showAimLine()
        shooter.shooterBody.texture = SKTexture(imageNamed: "hungry")
    }
    
    func updateAiming(to point: CGPoint) {
        shooter.aim(toward: point)
    }
    
    func cancelAiming() {
        shooter.hideAimLine()
        shooter.shooterBody.texture = SKTexture(imageNamed: "happy")
    }
    
    func createBall() -> BallNode {
        let ball = BallNode(type: .normal, radius: layoutInfo.ballRadius)
        ball.position = shooter.position
        activeBalls.append(ball)
        addChild(ball)
        return ball
    }
    
    func shootBall(_ ball: BallNode) {
        shooter.shoot(ball)
    }
    
    func addBlock(_ block: BlockNode) {
        blocks.append(block)
        addChild(block)
    }
    
    func removeBlock(_ block: BlockNode) {
        if let index = blocks.firstIndex(of: block) {
            blocks.remove(at: index)
        }
        block.removeFromParent()
    }
    
    func clearBlocks() {
        for block in blocks {
            block.removeFromParent()
        }
        blocks.removeAll()
    }
    
    func moveBlocksDown() {
        for block in blocks {
            let moveAction = SKAction.moveBy(x: 0, y: -30, duration: 0.5)
            block.run(moveAction)
        }
    }
    
    func reset() {
        gameStats.reset()
        gameInfo?.reset()
        clearBlocks()
        clearActiveBalls()
        shooter.position = layoutInfo.shooterPos
        shooter.reset()
    }
    
    func updateBallSpeeds(multiplier: CGFloat) {
        for ball in children.compactMap({ $0 as? BallNode }) {
            let velocity = ball.physicsBody?.velocity
            let newVelocity = CGVector(dx: (velocity?.dx ?? 0) * multiplier, dy: (velocity?.dy ?? 0) * multiplier)
            ball.physicsBody?.velocity = newVelocity
        }
    }

}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        
        if let ball = nodeA as? BallNode, let block = nodeB as? BlockNode {
            handleBallBlockCollision(ball: ball, block: block)
        } else if let ball = nodeB as? BallNode, let block = nodeA as? BlockNode {
            handleBallBlockCollision(ball: ball, block: block)
        }
    }
    
    private func handleBallBlockCollision(ball: BallNode, block: BlockNode) {
        block.hit()
        
        if block.hitPoints <= 0 {
            removeBlock(block)
            gameInfo?.incrementScore(by: 1)
            gameStats.incrementScore(by: 1)
        }
    }
}
