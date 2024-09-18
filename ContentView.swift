//
//  Untitled.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import GameplayKit
import SpriteKit
import SwiftUI

struct ContentView: View {

    let context = GameContext()

    var body: some View {
        ZStack {
            SpriteView(scene: context.scene, debugOptions: [])
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }
        .statusBarHidden()
    }
}

#Preview {
    ContentView()
}

