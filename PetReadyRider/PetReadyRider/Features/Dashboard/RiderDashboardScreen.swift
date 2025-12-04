import SwiftUI
import PetReadyShared

struct RiderDashboardScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    stats
                    activeMissionCard
                    availableJobsCard
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: {
                        HStack(spacing: 6) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Go Online").font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(colors: [Color(hex: "98D8AA"), Color(hex: "A0D8F1")], startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .shadow(color: Color(hex: "98D8AA").opacity(0.3), radius: 8, y: 4)
                    }
                }
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ready for Dispatch! 🚴")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Keep acceptance >90% for bonuses")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.95))
                    HStack(spacing: 12) {
                        Label("92%", systemImage: "checkmark.circle.fill")
                        Text("•")
                        Label("Level 3", systemImage: "star.fill")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 4)
                }
                Spacer()
                Text("🏍️").font(.system(size: 60))
            }
            .padding(24)
            .background(
                ZStack {
                    LinearGradient(colors: [Color(hex: "A0D8F1"), Color(hex: "98D8AA")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 180, height: 180)
                        .offset(x: 70, y: -50)
                        .blur(radius: 50)
                }
            )
            HStack(spacing: 16) {
                Spacer()
                Text("⚡").opacity(0.4)
                Text("⚡").opacity(0.4)
                Text("⚡").opacity(0.4)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(.white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "A0D8F1").opacity(0.3), radius: 20, y: 10)
    }

    private var stats: some View {
        HStack(spacing: 14) {
            statTile(icon: "✅", title: "Accept", value: "92%", colors: [Color(hex: "98D8AA"), Color(hex: "C8EED4")])
            statTile(icon: "⏱️", title: "Response", value: "2m", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
            statTile(icon: "⭐", title: "Rating", value: "4.8", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
        }
    }

    private func statTile(icon: String, title: String, value: String, colors: [Color]) -> some View {
        VStack(spacing: 10) {
            Text(icon).font(.system(size: 28))
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(title).font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(.white)
                RoundedRectangle(cornerRadius: 22).fill(
                    LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(colors[0].opacity(0.2), lineWidth: 2))
        .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
    }

    private var activeMissionCard: some View {
        riderCuteCard("Active Mission", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("🆘").font(.title3)
                            Text("SOS #123").font(.headline).foregroundStyle(.primary)
                        }
                        Text("Pickup in 8 minutes")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(hex: "FF9ECD"))
                    }
                    Spacer()
                }
                Divider()
                VStack(spacing: 8) {
                    riderCuteInfoRow(icon: "👤", title: "Owner: Mint", subtitle: "Contact available")
                    riderCuteInfoRow(icon: "🏥", title: "Destination", subtitle: "PetWell Siam")
                }
                Divider()
                HStack(spacing: 12) {
                    Label("Chat enabled", systemImage: "bubble.left.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {} label: {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                            Text("Navigate")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "FF9ECD"), in: Capsule())
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 6, y: 3)
                    }
                }
            }
        }
    }

    private var availableJobsCard: some View {
        riderCuteCard("Available Jobs", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            ForEach(0..<3, id: \.self) { idx in
                HStack(spacing: 14) {
                    Text("📦")
                        .font(.system(size: 32))
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(.white).shadow(color: .black.opacity(0.05), radius: 4, y: 2))
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Request #\(idx + 235)")
                            .font(.body.weight(.semibold))
                        HStack(spacing: 8) {
                            Label("15 min", systemImage: "clock.fill")
                            Text("•")
                            Label("6 km", systemImage: "location.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {} label: {
                        Text("Accept")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "A0D8F1"), in: Capsule())
                            .shadow(color: Color(hex: "A0D8F1").opacity(0.3), radius: 4, y: 2)
                    }
                }
                .padding(.vertical, 6)
                if idx < 2 {
                    Divider().padding(.leading, 64)
                }
            }
        }
    }
}
