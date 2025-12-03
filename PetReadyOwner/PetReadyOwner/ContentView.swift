//
//  ContentView.swift
//  PetReadyOwner
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI
import PetReadyShared

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        TabView {
            OwnerHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            OwnerPetsView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }

            OwnerHealthView()
                .tabItem {
                    Label("Health", systemImage: "cross.case.fill")
                }

            OwnerClinicsView()
                .tabItem {
                    Label("Clinics", systemImage: "map.fill")
                }

            OwnerChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }

            OwnerInfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
                }

            OwnerSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "heart.fill")
                }
        }
        .tint(Color(hex: "FF9ECD"))
    }
}

private struct OwnerHomeView: View {
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
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Home")
        }
    }

    private var homeHeroCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome back! 👋")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("Fluffy & Basil are safe today")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.95))
                    
                    HStack(spacing: 12) {
                        Label("2 vaccines", systemImage: "syringe.fill")
                        Text("•")
                        Label("Next: 7 days", systemImage: "calendar")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
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
            cuteActionRow(icon: "📱", title: "Register via Barcode", subtitle: "Scan physical tag", showChevron: true)
            Divider().padding(.leading, 50)
            cuteActionRow(icon: "📋", title: "Issue Health QR", subtitle: "Share vaccine proof", showChevron: true)
            Divider().padding(.leading, 50)
            cuteActionRow(icon: "🆘", title: "Start SOS", subtitle: "Emergency dispatch", badge: "Emergency", badgeColor: Color(hex: "FF9ECD"), showChevron: true)
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

private struct OwnerPetsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        petCard(name: "Fluffy \(index + 1)", type: "Dog", age: "\(index + 1) years old")
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("My Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 8, y: 4)
                    }
                }
            }
        }
    }

    private func petCard(name: String, type: String, age: String) -> some View {
        HStack(spacing: 16) {
            Text(type == "Dog" ? "🐶" : "🐱")
                .font(.system(size: 44))
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFB5D8").opacity(0.2), Color(hex: "FFD4E8").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.title3.bold())
                
                HStack(spacing: 8) {
                    Text(type)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "A0D8F1"), in: Capsule())
                    
                    Text(age)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFF0F5"), Color(hex: "FFFFFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "FFB5D8").opacity(0.2), lineWidth: 2)
        )
        .shadow(color: Color(hex: "FFB5D8").opacity(0.15), radius: 12, y: 6)
    }
}

private struct OwnerHealthView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Upcoming Vaccines", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        ForEach(0..<2, id: \.self) { idx in
                            cuteInfoRow(icon: "💉", title: "Rabies Booster", subtitle: "Due in 7 days", badge: "Soon", badgeColor: Color(hex: "FFE5A0"))
                            if idx == 0 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                    
                    cuteCard("Treatment Timeline", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<3, id: \.self) { idx in
                            cuteInfoRow(icon: "🩺", title: "Check-up visit", subtitle: "Feb \(15 + idx)", showChevron: true)
                            if idx < 2 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Health")
        }
    }
}

private struct OwnerClinicsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        clinicCard(name: "Vet Clinic \(index + 1)", distance: "\(0.5 + Double(index) * 0.3) km")
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Clinics")
        }
    }

    private func clinicCard(name: String, distance: String) -> some View {
        HStack(spacing: 16) {
            Text("🏥")
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "98D8AA").opacity(0.2), Color(hex: "C8EED4").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.body.weight(.semibold))
                
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(distance)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                Text("Map • Promotions • Booking")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white)
                
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "E8FFE8").opacity(0.5), Color(hex: "FFFFFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(hex: "98D8AA").opacity(0.2), lineWidth: 2)
        )
        .shadow(color: Color(hex: "98D8AA").opacity(0.12), radius: 10, y: 5)
    }
}

private struct OwnerChatView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Waiting Queue", gradient: [Color(hex: "FFE5A0").opacity(0.3), Color(hex: "FFF3D4").opacity(0.3)]) {
                        cuteInfoRow(icon: "⏱️", title: "Dr. Siri", subtitle: "ETA 5 minutes", badge: "Waiting", badgeColor: Color(hex: "FFE5A0"))
                    }
                    
                    cuteCard("Conversations", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<2, id: \.self) { idx in
                            cuteInfoRow(icon: "👨‍⚕️", title: "Vet chat #\(idx + 1)", subtitle: "Last message: 2h ago", showChevron: true)
                            if idx == 0 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Chat")
        }
    }
}

private struct OwnerInfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Government Alerts", gradient: [Color(hex: "FFE5E5"), Color(hex: "FFF0F0")]) {
                        cuteInfoRow(icon: "☀️", title: "Heat advisory", subtitle: "Bangkok area - keep pets cool", badge: "Active", badgeColor: Color(hex: "FF9ECD"))
                    }
                    
                    cuteCard("Education", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteInfoRow(icon: "📚", title: "Puppy care basics", subtitle: "Essential guide", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteInfoRow(icon: "❓", title: "Vaccination FAQ", subtitle: "Common questions", showChevron: true)
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Information")
        }
    }
}

private struct OwnerSettingsView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Account", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        cuteInfoRow(icon: "👤", title: "Profile", subtitle: "Edit your info", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteInfoRow(icon: "🔔", title: "Notifications", subtitle: "Manage alerts", showChevron: true)
                    }
                    
                    cuteCard("Preferences", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteInfoRow(icon: "🌐", title: "Language", subtitle: "TH / EN", showChevron: true)
                    }
                    
                    Button {
                        authService.logout()
                    } label: {
                        HStack {
                            Text("Logout")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                            Image(systemName: "arrow.right.square.fill")
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.top, 8)
                    
                    VStack(spacing: 12) {
                        Text("Made with 💖 for pets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Settings")
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

private func cuteActionRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
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

private func cuteInfoRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
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
        .environmentObject(AuthService(apiClient: APIClient(baseURL: URL(string: "https://api.petready.app/v1")!)))
}
