//
//  BallType.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SwiftUI

enum BallType: String, CaseIterable{
    case normal
    case double
    
    var textureName: String {
        switch self {
        case .normal:
            return ""
        case .double:
            return ""
        }
    }
    
    var damage: Double {
        switch self {
        case .normal:
            return 1.0
        case .double:
            return 2.0
        }
    }
    
    var color: UIColor {
        switch self {
        case .normal:
            return .white
        case .double:
            return .yellow
        }
    }
}
