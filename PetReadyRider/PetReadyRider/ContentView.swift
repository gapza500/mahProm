//
//  ContentView.swift
//  PetReadyRider
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RiderDashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            RiderJobsView()
                .tabItem { Label("Jobs", systemImage: "list.bullet.clipboard") }
            RiderWalletView()
                .tabItem { Label("Wallet", systemImage: "creditcard.fill") }
            RiderProfileView()
                .tabItem { Label("Profile", systemImage: "heart.fill") }
        }
        .tint(Color(hex: "A0D8F1"))
    }
}

private struct RiderDashboardView: View {
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
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Go Online")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "98D8AA"), Color(hex: "A0D8F1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
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
                Text("🏍️")
                    .font(.system(size: 60))
            }
            .padding(24)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "A0D8F1"), Color(hex: "98D8AA")],
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
                Text("⚡")
                    .font(.caption2)
                    .opacity(0.4)
                Text("⚡")
                    .font(.caption2)
                    .opacity(0.4)
                Text("⚡")
                    .font(.caption2)
                    .opacity(0.4)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "A0D8F1").opacity(0.3), radius: 20, y: 10)
    }

    private var stats: some View {
        HStack(spacing: 14) {
            cuteStatTile(icon: "✅", title: "Accept", value: "92%", colors: [Color(hex: "98D8AA"), Color(hex: "C8EED4")])
            cuteStatTile(icon: "⏱️", title: "Response", value: "2m", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
            cuteStatTile(icon: "⭐", title: "Rating", value: "4.8", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
        }
    }

    private func cuteStatTile(icon: String, title: String, value: String, colors: [Color]) -> some View {
        VStack(spacing: 10) {
            Text(icon)
                .font(.system(size: 28))
            
            Text(value)
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

    private var activeMissionCard: some View {
        cuteCard("Active Mission", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("🆘")
                                .font(.title3)
                            Text("SOS #123")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        Text("Pickup in 8 minutes")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(hex: "FF9ECD"))
                    }
                    Spacer()
                }
                
                Divider()
                
                VStack(spacing: 8) {
                    cuteInfoRow(icon: "👤", title: "Owner: Mint", subtitle: "Contact available")
                    cuteInfoRow(icon: "🏥", title: "Destination", subtitle: "PetWell Siam")
                }
                
                Divider()
                
                HStack(spacing: 12) {
                    Label("Chat enabled", systemImage: "bubble.left.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                    } label: {
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
        cuteCard("Available Jobs", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            ForEach(0..<3, id: \.self) { idx in
                HStack(spacing: 14) {
                    Text("📦")
                        .font(.system(size: 32))
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        )
                    
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
                    
                    Button {
                    } label: {
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

private struct RiderJobsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Available", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<5, id: \.self) { idx in
                            cuteJobRow(icon: "📦", title: "Job #\(idx + 300)", subtitle: "Standard delivery", showChevron: true)
                            if idx < 4 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                    
                    cuteCard("Scheduled", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        ForEach(0..<2, id: \.self) { idx in
                            cuteJobRow(icon: "📅", title: "Appointment \(idx + 1)", subtitle: "Tomorrow 9:00", badge: "Scheduled", badgeColor: Color(hex: "FFE5A0"))
                            if idx == 0 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Jobs")
        }
    }
}

private struct RiderWalletView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    balanceCard
                    historyCard
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Wallet")
        }
    }

    private var balanceCard: some View {
        cuteCard("Balance", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💰")
                        .font(.system(size: 40))
                    
                    Text("Payout balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("฿3,280")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "98D8AA"), Color(hex: "A0D8F1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                Button {
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title2)
                        Text("Withdraw")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "98D8AA"), Color(hex: "A0D8F1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: Color(hex: "98D8AA").opacity(0.3), radius: 8, y: 4)
                }
            }
        }
    }

    private var historyCard: some View {
        cuteCard("History", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            ForEach(0..<4, id: \.self) { idx in
                HStack(spacing: 14) {
                    Text("💵")
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Job #\(idx + 210)")
                            .font(.body.weight(.semibold))
                        Text("Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("+฿320")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color(hex: "98D8AA"))
                }
                .padding(.vertical, 6)
                
                if idx < 3 {
                    Divider().padding(.leading, 54)
                }
            }
        }
    }
}

private struct RiderProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Identity", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        cuteJobRow(icon: "📄", title: "Documents", subtitle: "Upload & verify", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteJobRow(icon: "🏍️", title: "Vehicle profile", subtitle: "Details & license", showChevron: true)
                    }
                    
                    cuteCard("Service", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteJobRow(icon: "🗺️", title: "Service areas", subtitle: "Coverage map", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteJobRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Made with 💖 for riders")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Profile")
        }
    }
}

// Cute UI components
private func cuteCard<Content: View>(_ title: String, gradient: [Color], @ViewBuilder content: () -> Content) -> some View {
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

private func cuteInfoRow(icon: String, title: String, subtitle: String) -> some View {
    HStack(spacing: 12) {
        Text(icon)
            .font(.system(size: 20))
        
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        Spacer()
    }
}

private func cuteJobRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
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

#Preview {
    ContentView()
}
