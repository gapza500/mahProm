import SwiftUI
import PetReadyShared

func cuteCard<Content: View>(_ title: String, gradient: [Color], @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 18) {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(DesignSystem.Colors.primaryText)
        content()
    }
    .padding(22)
    .background(
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(.white)
            RoundedRectangle(cornerRadius: 28).fill(
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

func cuteRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
    HStack(spacing: 14) {
        Text(icon)
            .font(.system(size: 28))
            .frame(width: 44, height: 44)
            .background(Circle().fill(DesignSystem.Colors.cardSurface).shadow(color: .black.opacity(0.05), radius: 4, y: 2))
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.body.weight(.semibold)).foregroundStyle(DesignSystem.Colors.primaryText)
            Text(subtitle).font(.caption).foregroundStyle(DesignSystem.Colors.secondaryText)
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
            Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(DesignSystem.Colors.mutedText)
        }
    }
    .padding(.vertical, 6)
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

struct PetRegistrationsTable: View {
    let pets: [Pet]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                headerRow
                Divider()
                ForEach(recentPets.prefix(8)) { pet in
                    row(for: pet)
                    Divider()
                }
            }
            .frame(minWidth: 520, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.7))
        )
    }

    private var recentPets: [Pet] {
        pets.sorted { $0.updatedAt > $1.updatedAt }
    }

    private var headerRow: some View {
        HStack(spacing: 12) {
            Text("Pet")
            Spacer()
            Text("Owner").frame(width: 100, alignment: .leading)
            Text("Species").frame(width: 80, alignment: .leading)
            Text("Status").frame(width: 80, alignment: .leading)
            Text("Last Update").frame(width: 140, alignment: .leading)
        }
        .font(.caption)
        .foregroundStyle(DesignSystem.Colors.secondaryText)
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
    }

    private func row(for pet: Pet) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                if let barcode = pet.barcodeId, !barcode.isEmpty {
                    Text("Barcode \(barcode)")
                        .font(.caption2)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                        .lineLimit(1)
                }
            }
            Spacer()
            Group {
                if let ownerId = pet.ownerId {
                    Text(ownerId.uuidString.prefix(6) + "…")
                } else {
                    Text("Unassigned")
                }
            }
            .font(.caption)
            .frame(width: 100, alignment: .leading)
            .foregroundStyle(pet.ownerId == nil ? DesignSystem.Colors.secondaryText : .primary)
            .lineLimit(1)
            Text(pet.species.rawValue.capitalized)
                .font(.caption)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)
            Text(statusLabel(for: pet.status))
                .font(.caption)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)
            Text(Self.dateFormatter.string(from: pet.updatedAt))
                .font(.caption)
                .frame(width: 140, alignment: .leading)
                .lineLimit(1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 10)
    }
}

private func statusLabel(for status: String) -> String {
    status
        .replacingOccurrences(of: "_", with: " ")
        .capitalized
}
