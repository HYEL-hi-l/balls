//
//  TargetLineNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class FSTargetLineNode: SKShapeNode {
    
    private let maxLineLength: CGFloat = 400
    private(set) var currentLength: CGFloat = 0
    private let dashLength: CGFloat
    private let dashSpacing: CGFloat
    
    init(ballRadius: CGFloat) {
        self.dashLength = ballRadius / 12
        self.dashSpacing = ballRadius * 4
        super.init()
        strokeColor = .white
        lineWidth = ballRadius * 2
        lineCap = .round
        alpha = 0.7
        zPosition = -1
        updateLine(length: 0, angle: .pi / 2)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}


// MARK: Helpers
extension FSTargetLineNode {
    
    func showLine() {
        self.isHidden = false
    }
    
    func hideLine() {
        self.isHidden = true
    }
    
    func updateLine(length: CGFloat, angle: CGFloat) {
        currentLength = min(length, maxLineLength)
        
        let path = createDottedLinePath(length: currentLength, angle: angle)
        self.path = path
    }
    
    func expandLine(from startPoint: CGPoint, to endPoint: CGPoint, angle: CGFloat) {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let distance = hypot(dx, dy)
        
        updateLine(length: distance, angle: angle)
    }
    
    private func createDottedLinePath(length: CGFloat, angle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        var currentLength: CGFloat = 0
        
        let startX: CGFloat = 0
        let startY: CGFloat = 0
        
        let dx = cos(angle)
        let dy = sin(angle)
        
        while currentLength < length {
            let nextLength = min(dashLength, length - currentLength)
            let startXSegment = startX + dx * currentLength
            let startYSegment = startY + dy * currentLength
            let endXSegment = startXSegment + dx * nextLength
            let endYSegment = startYSegment + dy * nextLength
            
            path.move(to: CGPoint(x: startXSegment, y: startYSegment))
            path.addLine(to: CGPoint(x: endXSegment, y: endYSegment))
            
            currentLength += nextLength + dashSpacing
        }
        
        return path
    }
    
}
