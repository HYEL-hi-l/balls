//
//  BlackNode.swift
//  balls iOS
//
//  Created by Sam Richard on 9/17/24.
//

import SpriteKit

class BlockNode: SKShapeNode {
    var hitPoints: Int
    var maxHitPoints: Int
    var textureNode: SKSpriteNode!
    var label: SKLabelNode!
    var textureAtlas: SKTextureAtlas
    let cornerRadius: CGFloat = 2.0
    let strokeWidth: CGFloat = 2.5
    
    init(size: CGSize, hitPoints: Int, atlas: SKTextureAtlas) {
        self.hitPoints = hitPoints
        self.maxHitPoints = hitPoints
        self.textureAtlas = atlas
        
        super.init()
        
        let rect = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)
        let bezierPath = UIBezierPath(roundedRect: rect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2), cornerRadius: cornerRadius)
        self.path = bezierPath.cgPath
        
        setupPhysics(size: size)
        setupTextureNode(size: size)
        setupLabel(size: size)
        
        updateAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics(size: CGSize) {
        physicsBody = SKPhysicsBody(rectangleOf: size, center: .zero)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Block
        physicsBody?.collisionBitMask = PhysicsCategory.Ball
        physicsBody?.contactTestBitMask = PhysicsCategory.Ball
    }
    
    private func setupTextureNode(size: CGSize) {
        let texture = textureAtlas.textureNamed("happy_facial")
        textureNode = SKSpriteNode(texture: texture)
//        textureNode.size = CGSize(width: size.width * 0.8, height: size.height * 0.8)
//        textureNode.setScale(0.9)
        textureNode.zPosition = 1
        addChild(textureNode)
    }
    
    private func setupLabel(size: CGSize) {
        label = SKLabelNode(text: "\(hitPoints)")
        label.fontName = "Arial"
        label.fontSize = 8
        label.fontColor = .black
        label.verticalAlignmentMode = .bottom
        label.horizontalAlignmentMode = .right
        label.position = CGPoint(x: size.width / 2 - size.width * 0.075, y: -size.height / 2 + size.height * 0.075)
        label.zPosition = 2
        addChild(label)
    }
    
    func hit() {
        hitPoints -= 1
        if hitPoints <= 0 {
            removeFromParent()
        } else {
            updateAppearance()
            label.text = "\(hitPoints)"
        }
    }
    
    private func updateAppearance() {
        let tensPlace = hitPoints / 10
        let onesPlace = hitPoints % 10
        
        let (currentColor, nextColor, textureName) = getColorAndTexture(for: tensPlace, onesPlace: onesPlace)
        
        textureNode.texture = textureAtlas.textureNamed(textureName)
        
        var blendFactor: CGFloat
        if tensPlace == 0 {
            if onesPlace < 5 {
                blendFactor = CGFloat(onesPlace) / 5.0
            } else {
                blendFactor = CGFloat(onesPlace - 5) / 5.0
            }
        } else {
            blendFactor = CGFloat(onesPlace) / 10.0
        }
        fillColor = blend(color1: currentColor, color2: nextColor, factor: blendFactor)
        
        strokeColor = fillColor.darker()
        lineWidth = strokeWidth

    }
    
    private func getColorAndTexture(for tensPlace: Int, onesPlace: Int) -> (UIColor, UIColor, String) {
        switch tensPlace {
        case 0:
            if onesPlace <= 4 {
                return (UIColor(hex: "FFCF69"), UIColor(hex: "FA9049"), "happy_facial")
            } else {
                return (UIColor(hex: "FA9049"), UIColor(hex: "FF69B1"), "boring_facial")

            }
        case 1:
            return (UIColor(hex: "FF69B1"), UIColor(hex: "BE8BFF"), "laughing_facial")
        case 2:
            return (UIColor(hex: "BE8BFF"), UIColor(hex: "429FD8"), "hungry_facial")
        case 3:
            return (UIColor(hex: "429FD8"), UIColor(hex: "07B495"), "peace_facial")
        case 4:
            return (UIColor(hex: "07B495"), UIColor(hex: "07B495"), "sick_facial")
        case 5:
            return (UIColor(hex: "07B495"), UIColor(hex: "46DF83"), "sick_facial")
        case 6:
            return (UIColor(hex: "46DF83"), UIColor(hex: "46DF83"), "dead_facial")
        case 7:
            return (UIColor(hex: "46DF83"), UIColor(hex: "FAFAFA"), "dead_facial")
        case 8:
            return (UIColor(hex: "FAFAFA"), UIColor(hex: "FAFAFA"), "wink_facial")
        case 9:
            return (UIColor(hex: "FAFAFA"), UIColor(hex: "F3504C"), "wink_facial")
        case 10, 11, 12, 13, 14, 15, 16, 17, 18:
            return (UIColor(hex: "F3504C"), UIColor(hex: "F3504C"), "angry_facial")
        case 19:
            return (UIColor(hex: "F3504C"), UIColor(hex: "B3F065"), "angry_facial")
        default:
            return (UIColor(hex: "B3F065"), UIColor(hex: "B3F065"), "alien_facial")
        }
    }
    
    private func blend(color1: UIColor, color2: UIColor, factor: CGFloat) -> UIColor {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return UIColor(
            red: red1 + (red2 - red1) * factor,
            green: green1 + (green2 - green1) * factor,
            blue: blue1 + (blue2 - blue1) * factor,
            alpha: alpha1 + (alpha2 - alpha1) * factor
        )
    }

}


extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    func darker() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(r - 0.25, 0), green: max(g - 0.25, 0), blue: max(b - 0.25, 0), alpha: a)
    }
}
