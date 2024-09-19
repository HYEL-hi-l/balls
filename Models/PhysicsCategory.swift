//
//  PhysicsCategory.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import Foundation

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Ball: UInt32 = 0b1
    static let Wall: UInt32 = 0b10
    static let Block: UInt32 = 0b100
    static let BonusBall: UInt32 = 0b1000
    static let PowerUp: UInt32 = 0b10000
    static let BottomLine: UInt32 = 0b100000
    static let NoMansLand: UInt32 = 0b1000000
}
