import SwiftUI
import PetReadyShared

// Shared styling helpers used across owner features
func cuteCard<Content: View>(
    _ title: String,
    gradient: [Color] = DesignSystem.Gradients.ownerCard,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: 18) {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(DesignSystem.Colors.primaryText)
        content()
    }
    .padding(22)
    .background(
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.Metrics.cardCornerRadius)
                .fill(DesignSystem.Colors.cardSurface)
            RoundedRectangle(cornerRadius: DesignSystem.Metrics.cardCornerRadius)
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    )
    .overlay(
        RoundedRectangle(cornerRadius: DesignSystem.Metrics.cardCornerRadius)
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
                    .fill(DesignSystem.Colors.cardSurface)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )

        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.primaryText)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }

        Spacer()

        if let badge = badge, let badgeColor = badgeColor {
            Text(badge)
                .font(.caption2.weight(.bold))
                .foregroundStyle(DesignSystem.Colors.onAccentText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(badgeColor, in: Capsule())
                .shadow(color: badgeColor.opacity(0.3), radius: 4, y: 2)
        }

        if showChevron {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(DesignSystem.Colors.mutedText)
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
                    .fill(DesignSystem.Colors.cardSurface)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.primaryText)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }

        Spacer()

        if let badge = badge, let badgeColor = badgeColor {
            Text(badge)
                .font(.caption2.weight(.bold))
                .foregroundStyle(DesignSystem.Colors.onAccentText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(badgeColor, in: Capsule())
                .shadow(color: badgeColor.opacity(0.3), radius: 4, y: 2)
        }

        if showChevron {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(DesignSystem.Colors.mutedText)
        }
    }
    .padding(.vertical, 4)
}
