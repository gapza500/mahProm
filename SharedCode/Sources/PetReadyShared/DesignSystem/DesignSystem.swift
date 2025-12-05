import SwiftUI

public enum DesignSystem {
    public enum Colors {
        public static let appBackground = Color.dynamic(lightHex: "FFF9FB", darkHex: "524C61") // as before

        // Card/box surfaces: neutral but colored for accents
        public static let cardSurface   = Color.dynamic(lightHex: "FFFFFF", darkHex: "231C18") // deep brown/earth for general cards
        public static let cardStroke    = Color.dynamic(lightHex: "F2E9F0", darkHex: "493825")

        // Accents (now truly deep and analogous to light mode)
        public static let accentPink    = Color.dynamic(lightHex: "FF9ECD", darkHex: "91304D") // deep berry
        public static let accentBlue    = Color.dynamic(lightHex: "A0D8F1", darkHex: "19324D") // dark blue
        public static let accentMint    = Color.dynamic(lightHex: "98D8AA", darkHex: "284235") // deep pine
        public static let accentPeach   = Color.dynamic(lightHex: "FFE5A0", darkHex: "6A4A1B") // rich brown/gold

        // Text
        public static let primaryText   = Color.dynamic(lightHex: "1C1D21", darkHex: "F4EFE7")
        public static let secondaryText = Color.dynamic(lightHex: "6F6F80", darkHex: "C9C6BD")
        public static let mutedText     = Color.dynamic(lightHex: "9C9DB0", darkHex: "837A8D")
        public static let onAccentText  = Color.dynamic(lightHex: "FFFFFF", darkHex: "F7F4ED")
    }

    public enum Gradients {
        // Each card/box now has a dark mode color that matches the light mode's intent,
        // but is rich and deep, not gray, not pastel:
        public static let ownerCard: [Color] = [
            Color.dynamic(lightHex: "FFE5EC", darkHex: "3A1A22"), // blush → deep wine
            Color.dynamic(lightHex: "FFF0F5", darkHex: "231116")
        ]
        public static let statusTile: [Color] = [
            Color.dynamic(lightHex: "FFE5A0", darkHex: "6A4A1B"), // yellow → brown/gold
            Color.dynamic(lightHex: "FFF3D4", darkHex: "3B2714")
        ]
        public static let quickAction: [Color] = [
            Color.dynamic(lightHex: "E8F4FF", darkHex: "19324D"), // blue → dark blue
            Color.dynamic(lightHex: "F0F8FF", darkHex: "222A36")
        ]
        public static let vaccineCard: [Color] = [
            Color.dynamic(lightHex: "98D8AA", darkHex: "284235"), // mint/green → deep pine
            Color.dynamic(lightHex: "E8FFE8", darkHex: "16251B")
        ]
        public static let emergencyCard: [Color] = [
            Color.dynamic(lightHex: "FF9ECD", darkHex: "91304D"), // pink → berry/burgundy
            Color.dynamic(lightHex: "FFE5EC", darkHex: "4C1B2A")
        ]
        public static let heroCard: [Color] = [
            Color.dynamic(lightHex: "A0D8F1", darkHex: "233042"), // blue → midnight blue
            Color.dynamic(lightHex: "FFB5D8", darkHex: "3A2132")  // pink → dark wine
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
