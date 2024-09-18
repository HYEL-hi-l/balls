//
//  ColorsInfo.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import UIKit

struct ColorsInfo {
    let backgroundTextureName: String
    let titleTextureName: String
    let backgroundColor: UIColor
    let gameOverXTexture: String
    let timerVisualTexture: String
    let findCardVisualTexture: String
    let themeColor: UIColor
    let borderColor: UIColor
    let isSuffixYouAdded: Bool
    let profileLabelColor: UIColor
    let profileNodeNeedBorder: Bool
}

extension ColorsInfo {
    static var eventColors: ColorsInfo {
        // TODO: Customize
        return .init(
            backgroundTextureName: "memory_bg",
            titleTextureName: "memory_title",
            backgroundColor: .inchworm,
            gameOverXTexture: "memory_x",
            timerVisualTexture: "memory_timer",
            findCardVisualTexture: "memory_find",
            themeColor: .purple,
            borderColor: .hyelDarkPurple,
            isSuffixYouAdded: true,
            profileLabelColor: .black,
            profileNodeNeedBorder: true
        )
    }
    
    static var defaultColors: MMColorsInfo {
        return .init(
            backgroundTextureName: "memory_bg",
            titleTextureName: "memory_title",
            backgroundColor: .black,
            gameOverXTexture: "memory_x",
            timerVisualTexture: "memory_timer",
            findCardVisualTexture: "memory_find",
            themeColor: .hyelDarkPurple,
            borderColor: .hyelDarkPurple,
            isSuffixYouAdded: false,
            profileLabelColor: .white,
            profileNodeNeedBorder: false
        )
    }
}
