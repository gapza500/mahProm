import SwiftUI
import PetReadyShared

final class AdminDependencies {
    static let shared = AdminDependencies()
    let petListViewModel: PetListViewModel

    private init() {
        let repository = PetRepositoryFactory.makeRepository()
        let service = PetService(repository: repository)
        petListViewModel = PetListViewModel(service: service)
    }
}

struct ContentView: View {
    @StateObject private var petListViewModel = AdminDependencies.shared.petListViewModel

    var body: some View {
        TabView {
            AdminDashboardView(viewModel: petListViewModel)
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            ApprovalsView()
                .tabItem { Label("Approvals", systemImage: "checkmark.circle.fill") }
            AnnouncementsView()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
            AdminSettingsView()
                .tabItem { Label("Settings", systemImage: "heart.fill") }
        }
        .tint(Color(hex: "FF9ECD"))
    }
}

private struct AdminDashboardView: View {
    @ObservedObject var viewModel: PetListViewModel
    @State private var didTriggerInitialLoad = false
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    metrics
                    
                    cuteCard("🚨 Emergency Care", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        cuteRow(icon: "🆘", title: "SOS cases", subtitle: "2 little ones need help now", badge: "Active", badgeColor: Color(hex: "FF9ECD"))
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "👨‍⚕️", title: "Online vets & helpers", subtitle: "45 vets • 28 riders ready to help")
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "☀️", title: "Weather alert", subtitle: "Hot day in Bangkok - keep pets cool!")
                    }
                    
                    cuteCard("📢 Announcements", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteRow(icon: "📣", title: "Send announcement", subtitle: "Broadcast to all pet parents", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "📅", title: "Scheduled messages", subtitle: "2 announcements tomorrow", badge: "2", badgeColor: Color(hex: "A0D8F1"))
                    }
                    
                    recentPetRegistrations
                }
                .padding()
            }
            .refreshable {
                isLoading = true
                await viewModel.loadPets()
                isLoading = false
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Pet Care Central")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        HStack(spacing: 6) {
                            Text("📢")
                            Text("Broadcast")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
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
            .task {
                guard !didTriggerInitialLoad else { return }
                didTriggerInitialLoad = true
                await viewModel.loadPets()
                isLoading = false
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("🌟")
                            .font(.title)
                        Text("National Pet Dashboard")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                    
                    Text("Keeping all furry friends safe & happy!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.95))
                    
                    HStack(spacing: 12) {
                        Label("5min", systemImage: "clock.fill")
                        Text("•")
                        Label("99% happy", systemImage: "heart.fill")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 4)
                }
                Spacer()
                Text("🐶")
                    .font(.system(size: 70))
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
                        .frame(width: 200, height: 200)
                        .offset(x: 80, y: -60)
                        .blur(radius: 50)
                    
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .offset(x: -70, y: 40)
                        .blur(radius: 40)
                }
            )
            
            // Cute paw prints decoration
            HStack(spacing: 20) {
                ForEach(0..<5) { _ in
                    Text("🐾")
                        .font(.caption2)
                        .opacity(0.4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "FFB5D8").opacity(0.3), radius: 20, y: 10)
    }

    private var metrics: some View {
        HStack(spacing: 14) {
            cuteMetricTile(emoji: "🆘", title: "SOS", value: "2", subtitle: "Active", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            cuteMetricTile(emoji: "✅", title: "Approvals", value: "8", subtitle: "Waiting", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            cuteMetricTile(emoji: "🔔", title: "Alerts", value: "1", subtitle: "Active", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
        }
    }

    private func cuteMetricTile(emoji: String, title: String, value: String, subtitle: String, colors: [Color]) -> some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 32))
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            VStack(spacing: 2) {
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(colors[0].opacity(0.2), lineWidth: 2)
        )
        .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
    }

    private var recentPetRegistrations: some View {
        cuteCard("🐾 Recent Pet Registrations", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView().tint(Color(hex: "FF9ECD"))
                    Text("Fetching the latest pets…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.pets.isEmpty {
                VStack(spacing: 8) {
                    Text("🐶")
                        .font(.largeTitle)
                    Text("No new registrations yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                PetRegistrationsTable(pets: viewModel.pets)
                    .padding(.top, 4)
            }
        }
    }
}

private struct ApprovalsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("🩺 Vet Applications", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        ForEach(0..<3, id: \.self) { idx in
                            if idx > 0 {
                                Divider().padding(.leading, 50)
                            }
                            cuteRow(
                                icon: "👨‍⚕️",
                                title: "Dr. Applicants #\(idx + 41)",
                                subtitle: "License verification in progress",
                                showChevron: true
                            )
                        }
                    }
                    
                    cuteCard("🚴 Rider Applications", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<5, id: \.self) { idx in
                            if idx > 0 {
                                Divider().padding(.leading, 50)
                            }
                            cuteRow(
                                icon: "🚴",
                                title: "Rider #\(idx + 120)",
                                subtitle: "Documents ready for review",
                                showChevron: true
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("✅ Approvals")
        }
    }
}

private struct AnnouncementsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("🔴 Active Alerts", gradient: [Color(hex: "FFE5E5"), Color(hex: "FFF0F0")]) {
                        cuteRow(
                            icon: "☀️",
                            title: "Heat warning: Bangkok",
                            subtitle: "Sent to all pet parents & vets",
                            badge: "Live",
                            badgeColor: Color(hex: "FF9ECD"),
                            showChevron: true
                        )
                    }
                    
                    cuteCard("📝 Draft Messages", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        cuteRow(
                            icon: "🤧",
                            title: "Pet flu advisory",
                            subtitle: "Scheduled for tomorrow 9 AM",
                            badge: "Tomorrow",
                            badgeColor: Color(hex: "FFE5A0"),
                            showChevron: true
                        )
                        Divider().padding(.leading, 50)
                        cuteRow(
                            icon: "🎉",
                            title: "Holiday closure notice",
                            subtitle: "Waiting for final approval",
                            showChevron: true
                        )
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("🔔 Alerts")
        }
    }
}

private struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("💚 System Health", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        cuteRow(icon: "💯", title: "Uptime", subtitle: "99.9% - Amazing!", badge: "Excellent", badgeColor: Color(hex: "98D8AA"))
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "⏱️", title: "Response time", subtitle: "Average 7 minutes")
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "📈", title: "Happy users", subtitle: "+18% more pets helped", badge: "+18%", badgeColor: Color(hex: "A0D8F1"))
                    }
                    
                    cuteCard("🗺️ Regional Activity", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        VStack(spacing: 16) {
                            regionBubble("🏙️ Bangkok", percentage: 45, color: Color(hex: "FFB5D8"))
                            regionBubble("🏔️ Chiang Mai", percentage: 22, color: Color(hex: "A0D8F1"))
                            regionBubble("🏖️ Phuket", percentage: 15, color: Color(hex: "FFE5A0"))
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("📊 Analytics")
        }
    }
    
    private func regionBubble(_ name: String, percentage: Int, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Text("\(percentage)")
                        .font(.title3.bold())
                        .foregroundStyle(color)
                    Text("%")
                        .font(.caption2.bold())
                        .foregroundStyle(color.opacity(0.7))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body.weight(.semibold))
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(percentage) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct AdminSettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("⚙️ System Settings", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteRow(icon: "🎚️", title: "Feature toggles", subtitle: "Turn features on/off", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "🗺️", title: "Coverage areas", subtitle: "Manage service regions", showChevron: true)
                    }
                    
                    cuteCard("👥 Team Management", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        cuteRow(icon: "👨‍💼", title: "Admin team", subtitle: "Manage administrators", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "🔔", title: "Notifications", subtitle: "Alert preferences", showChevron: true)
                    }
                    
                    // Cute footer
                    VStack(spacing: 12) {
                        Text("🐾")
                            .font(.title)
                        Text("Made with love for pets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("🐶 🐱 🐰 🐹 🐦")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("❤️ Settings")
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

private func cuteRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
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

private struct PetRegistrationsTable: View {
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
            Text("Owner").font(.caption).foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text("Species").font(.caption).foregroundStyle(.secondary)
                .frame(width: 70, alignment: .leading)
            Text("Status").font(.caption).foregroundStyle(.secondary)
                .frame(width: 70, alignment: .leading)
            Text("Last Update").font(.caption).foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
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
