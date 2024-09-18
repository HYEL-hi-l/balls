//
//  LayoutInfo.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import UIKit

struct LayoutInfo {
    static let initialRows: Int = 4
    var columns:Int = 7
    
    var screenSize: CGSize = .zero
    var bottomLineY: CGFloat = .zero

    var blockSpacing: CGFloat = 10
    var blockSize: CGSize = .zero
    
    var playAreaOffset: CGFloat = 0
    var playAreaSize: CGSize = .zero
    var playAreaPos: CGPoint = .zero
    
    var shooterSize: CGSize = .zero
    var shooterPos: CGPoint = .zero
    
    var fastForwardPos: CGPoint = .zero
    var fastForwardPadding: CGFloat = 25
    
    var ballRadius: CGFloat = 10
    
}
