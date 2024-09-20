//
//  LayoutInfo.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import UIKit

struct FSLayoutInfo {
    static let initialRows: Int = 2
    var columns:Int = 7
    
    var screenSize: CGSize = .zero
    var bottomLineY: CGFloat = .zero
    var gameOverLineY: CGFloat = .zero

    var blockSpacing: CGFloat = 6
    var blockSize: CGSize = .zero
    
    var playAreaOffset: CGFloat = 0
    var playAreaSize: CGSize = .zero
    var playAreaPos: CGPoint = .zero
    
    var shooterPos: CGPoint = .zero
    
    var powerUpSlotSpacing: CGFloat = 20
    var powerUpSlotSize: CGSize = .zero
    var powerUpSlotYPos: CGFloat = 0
    
    var fastForwardPos: CGPoint = .zero
    var fastForwardPadding: CGFloat = 25
    
    var roundCountNodePos: CGPoint = .zero
    var roundCountNodeSize: CGSize = .zero
    var roundCountNodeOffset: CGFloat = 60
    
    var ballRadius: CGFloat = 10
    
}
