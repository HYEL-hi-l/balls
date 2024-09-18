//
//  TargetLineNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class TargetLineNode: SKShapeNode {
    
    private let maxLineLength: CGFloat = 150
    private(set) var currentLength: CGFloat = 0
    private let dashLength: CGFloat = 3
    private let dashSpacing: CGFloat = 8
    
    override init() {
        super.init()
        strokeColor = .white
        lineWidth = 6
        lineCap = .round
        updateLine(length: 0, angle: .pi / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func hideLine() {
        self.isHidden = true
    }
    
    func showLine() {
        self.isHidden = false
    }
}
