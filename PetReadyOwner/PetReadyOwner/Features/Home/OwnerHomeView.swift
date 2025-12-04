import SwiftUI
import PetReadyShared

struct OwnerHomeView: View {
    @State private var isShowingBarcodeClaim = false
    @State private var isShowingScanner = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    homeHeroCard
                    statusGrid
                    quickHubCard
                    upcomingCareCard
                    emergencyCard
                }
                .padding()
            }
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Scan Barcode") { isShowingScanner = true }
                        Button("Enter Code Manually") { isShowingBarcodeClaim = true }
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingBarcodeClaim) {
            NavigationStack { BarcodeClaimView() }
        }
        .sheet(isPresented: $isShowingScanner) {
            NavigationStack { PetScanPlaceholderView() }
        }
    }

    private var homeHeroCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome back! 👋")
                        .font(.title2.bold())
                        .foregroundStyle(DesignSystem.Colors.onAccentText)

                    Text("Fluffy & Basil are safe today")
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.95))

                    HStack(spacing: 12) {
                        Label("2 vaccines", systemImage: "syringe.fill")
                        Text("•")
                        Label("Next: 7 days", systemImage: "calendar")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.9))
                    .padding(.top, 4)
                }
                Spacer()
                Text("🐶")
                    .font(.system(size: 60))
            }
            .padding(24)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "FFB5D8"), Color(hex: "A0D8F1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 180, height: 180)
                        .offset(x: 70, y: -50)
                        .blur(radius: 50)
                }
            )

            HStack(spacing: 16) {
                Spacer()
                Text("🐾")
                    .font(.caption2)
                    .opacity(0.4)
                Text("🐾")
                    .font(.caption2)
                    .opacity(0.4)
                Text("🐾")
                    .font(.caption2)
                    .opacity(0.4)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "FFB5D8").opacity(0.3), radius: 20, y: 10)
    }

    private var statusGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            cuteStatusTile(icon: "🐾", title: "Pets", subtitle: "3 active", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            cuteStatusTile(icon: "⏱️", title: "Chat", subtitle: "<5 min", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
            cuteStatusTile(icon: "💉", title: "Vaccines", subtitle: "2 soon", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            cuteStatusTile(icon: "📍", title: "Nearby", subtitle: "1.2 km", colors: [Color(hex: "98D8AA"), Color(hex: "C8EED4")])
        }
    }

    private func cuteStatusTile(icon: String, title: String, subtitle: String, colors: [Color]) -> some View {
        VStack(spacing: 10) {
            Text(icon)
                .font(.system(size: 28))

            Text(subtitle)
                .font(.title3.bold())
                .foregroundStyle(
                    LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white)

                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(colors[0].opacity(0.2), lineWidth: 2)
        )
        .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
    }

    private var quickHubCard: some View {
        cuteCard("Quick Actions", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            Button {
                isShowingBarcodeClaim = true
            } label: {
                cuteActionRow(icon: "📱", title: "Register via Barcode", subtitle: "Scan or enter code", showChevron: true)
            }
            Divider().padding(.leading, 50)
            NavigationLink {
                FeaturePlaceholderView(
                    title: "Health QR Pass",
                    message: "A digital card that pulls vaccination records from Firestore so owners can share proof instantly.",
                    icon: "🪪",
                    highlights: [
                        "One-tap QR for check-ins at clinics",
                        "Expirable links for boarding / grooming partners"
                    ]
                )
                .navigationTitle("Health QR")
            } label: {
                cuteActionRow(icon: "📋", title: "Issue Health QR", subtitle: "Share vaccine proof", showChevron: true)
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 50)
            NavigationLink {
                FeaturePlaceholderView(
                    title: "SOS Dispatch",
                    message: "Preview of the panic flow that alerts riders + nearby vets while sharing location snapshots.",
                    icon: "🚨",
                    highlights: [
                        "Sends GPS & pet profile automatically",
                        "Hands off to push + realtime channels"
                    ]
                )
                .navigationTitle("SOS Preview")
            } label: {
                cuteActionRow(
                    icon: "🆘",
                    title: "Start SOS",
                    subtitle: "Emergency dispatch",
                    badge: "Emergency",
                    badgeColor: Color(hex: "FF9ECD"),
                    showChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var upcomingCareCard: some View {
        cuteCard("Upcoming Care", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
            cuteInfoRow(icon: "💉", title: "Rabies booster", subtitle: "Due in 7 days")
            Divider().padding(.leading, 50)
            cuteInfoRow(icon: "🩺", title: "General check-up", subtitle: "Mar 24")
        }
    }

    private var emergencyCard: some View {
        cuteCard("Emergency Toolkit", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            cuteInfoRow(icon: "✅", title: "SOS profile", subtitle: "Up to date")
            Divider().padding(.leading, 50)
            cuteInfoRow(icon: "🏥", title: "Nearest clinic", subtitle: "PetWell Siam")
        }
    }
}
