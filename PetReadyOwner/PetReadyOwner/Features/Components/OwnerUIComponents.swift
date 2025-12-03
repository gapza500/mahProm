import SwiftUI

// Shared styling helpers used across owner features
func cuteCard<Content: View>(_ title: String, gradient: [Color], @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 18) {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(.primary)
        content()
    }
    .padding(22)
    .background(
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(.white)

            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    )
    .overlay(
        RoundedRectangle(cornerRadius: 28)
            .stroke(gradient[0].opacity(0.3), lineWidth: 2)
    )
    .shadow(color: gradient[0].opacity(0.15), radius: 16, y: 8)
}

func cuteActionRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
    HStack(spacing: 14) {
        Text(icon)
            .font(.system(size: 28))
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )

        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        Spacer()

        if let badge = badge, let badgeColor = badgeColor {
            Text(badge)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(badgeColor, in: Capsule())
                .shadow(color: badgeColor.opacity(0.3), radius: 4, y: 2)
        }

        if showChevron {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
    }
    .padding(.vertical, 6)
}

func cuteInfoRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
    HStack(spacing: 14) {
        Text(icon)
            .font(.system(size: 24))
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        Spacer()

        if let badge = badge, let badgeColor = badgeColor {
            Text(badge)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(badgeColor, in: Capsule())
                .shadow(color: badgeColor.opacity(0.3), radius: 4, y: 2)
        }

        if showChevron {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
    }
    .padding(.vertical, 4)
}

extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
