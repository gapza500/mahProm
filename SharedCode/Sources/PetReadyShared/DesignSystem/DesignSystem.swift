import SwiftUI

public enum DesignSystem {
    public enum Colors {
        public static let appBackground = Color.dynamic(lightHex: "FFF9FB", darkHex: "524C61") // earth-tone purple
        public static let cardSurface = Color.dynamic(lightHex: "FFFFFF", darkHex: "3C3647")
        public static let cardStroke = Color.dynamic(lightHex: "F2E9F0", darkHex: "5C5568")
        public static let accentPink = Color.dynamic(lightHex: "FF9ECD", darkHex: "B89A79")
        public static let accentBlue = Color.dynamic(lightHex: "A0D8F1", darkHex: "666D7D")
        public static let accentMint = Color.dynamic(lightHex: "98D8AA", darkHex: "A4B089")
        public static let accentPeach = Color.dynamic(lightHex: "FFE5A0", darkHex: "C7C49F")
        public static let subtleText = Color.dynamic(lightHex: "7A7A89", darkHex: "E9E3D7")
    }

    public enum Gradients {
        public static let softBlue: [Color] = [
            Color.dynamic(lightHex: "E8F4FF", darkHex: "737D92"),
            Color.dynamic(lightHex: "F0F8FF", darkHex: "666D7D")
        ]

        public static let blush: [Color] = [
            Color.dynamic(lightHex: "FFE5EC", darkHex: "AB8072"),
            Color.dynamic(lightHex: "FFF0F5", darkHex: "8A8172")
        ]

        public static let lavender: [Color] = [
            Color.dynamic(lightHex: "FFE5F1", darkHex: "8A8172"),
            Color.dynamic(lightHex: "FFF0F7", darkHex: "6D5F63")
        ]

        public static let mint: [Color] = [
            Color.dynamic(lightHex: "E8FFE8", darkHex: "A4B089"),
            Color.dynamic(lightHex: "F0FFF0", darkHex: "7F8E6C")
        ]

        public static let heroSunrise: [Color] = [
            Color.dynamic(lightHex: "FFB5D8", darkHex: "B89A79"),
            Color.dynamic(lightHex: "A0D8F1", darkHex: "666D7D")
        ]
    }

    public enum Metrics {
        public static let cardCornerRadius: CGFloat = 24
        public static let heroCornerRadius: CGFloat = 28
        public static let sectionSpacing: CGFloat = 18
    }
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
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
            (a, r, g, b) = (255, 255, 255, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static func dynamic(lightHex: String, darkHex: String) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ?
                UIColor(hex: darkHex) :
                UIColor(hex: lightHex)
        })
        #else
        return Color(hex: lightHex)
        #endif
    }
}

#if canImport(UIKit)
import UIKit

private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
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
            (a, r, g, b) = (255, 255, 255, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
#endif
