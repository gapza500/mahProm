import SwiftUI

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
            .background(Circle().fill(.white).shadow(color: .black.opacity(0.05), radius: 4, y: 2))
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.body.weight(.semibold)).foregroundStyle(.primary)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
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
            Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
        }
    }
    .padding(.vertical, 6)
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
        VStack(spacing: 0) {
            headerRow
            Divider()
            ForEach(recentPets.prefix(8)) { pet in
                row(for: pet)
                Divider()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.7))
        )
    }

    private var recentPets: [Pet] {
        pets.sorted { $0.updatedAt > $1.updatedAt }
    }

    private var headerRow: some View {
        HStack {
            Text("Pet").font(.caption).foregroundStyle(.secondary)
            Spacer()
            Text("Owner").font(.caption).foregroundStyle(.secondary).frame(width: 90, alignment: .leading)
            Text("Species").font(.caption).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
            Text("Status").font(.caption).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
            Text("Last Update").font(.caption).foregroundStyle(.secondary).frame(width: 120, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func row(for pet: Pet) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name).font(.subheadline).bold()
                if let barcode = pet.barcodeId, !barcode.isEmpty {
                    Text("Barcode \(barcode)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(pet.ownerId.uuidString.prefix(6) + "…")
                .font(.caption)
                .frame(width: 90, alignment: .leading)
            Text(pet.species.rawValue.capitalized)
                .font(.caption)
                .frame(width: 70, alignment: .leading)
            Text(pet.status.capitalized)
                .font(.caption)
                .frame(width: 70, alignment: .leading)
            Text(Self.dateFormatter.string(from: pet.updatedAt))
                .font(.caption)
                .frame(width: 120, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
