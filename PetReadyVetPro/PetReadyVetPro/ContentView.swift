import SwiftUI


struct ContentView: View {
    var body: some View {
        TabView {
            VetDashboard()
                .tabItem { Label("Dashboard", systemImage: "rectangle.grid.2x2.fill") }
            PatientsView()
                .tabItem { Label("Patients", systemImage: "stethoscope") }
            QueueView()
                .tabItem { Label("Queue", systemImage: "clock.arrow.circlepath") }
            ContentHubView()
                .tabItem { Label("Content", systemImage: "text.book.closed.fill") }
            VetSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Color(hex: "FF9ECD"))
    }
}


private struct VetDashboard: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    vetHeroCard
                    metricGrid
                    queueCard
                    quickActionsCard
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Dashboard")
        }
    }

    // Hero Banner
    private var vetHeroCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Good Morning, Dr. Siri! 👩‍⚕️")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("You’re on a 4.2⭐ response streak")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.95))
                
                HStack(spacing: 8) {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                    Text("•")
                    Text("Reply < 5 min")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 4)
            }
            Spacer()
        }
        .padding(24)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "A0D8F1"), Color(hex: "FFB5D8")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .offset(x: 100, y: -40)
                    .blur(radius: 30)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "A0D8F1").opacity(0.4), radius: 16, y: 8)
    }

    // Metrics (Today, Queue, Rating)
    private var metricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            cuteStatusTile(icon: "🗓️", title: "Today", subtitle: "11", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            cuteStatusTile(icon: "⚡️", title: "Queue", subtitle: "3", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            cuteStatusTile(icon: "⭐️", title: "Rating", subtitle: "4.9", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
        }
    }

    
    private var queueCard: some View {
        cuteCard("Consultation Queue", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            ForEach(0..<3, id: \.self) { idx in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Owner #\(idx + 241)")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Fluffy – Itchy skin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Join") {}
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "FF9ECD"), in: Capsule())
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 4, y: 2)
                }
                .padding(.vertical, 6)
                if idx < 2 { Divider() }
            }
        }
    }

    
    private var quickActionsCard: some View {
        cuteCard("Quick Actions", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
            cuteActionRow(icon: "💬", title: "Tele-chat room", subtitle: "Reply instantly", showChevron: true)
            Divider().padding(.leading, 50)
            cuteActionRow(icon: "💊", title: "Prescription", subtitle: "Send PDF/Photo", showChevron: true)
            Divider().padding(.leading, 50)
            cuteActionRow(icon: "📹", title: "Video Handoff", subtitle: "Switch to video", badge: "Pro", badgeColor: Color(hex: "98D8AA"), showChevron: true)
        }
    }
}


private struct PatientsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { idx in
                        cuteCard("", gradient: [Color.white, Color.white]) {
                            HStack(spacing: 16) {
                                Text("🐶")
                                    .font(.largeTitle)
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: "FFF0F5"), in: Circle())
                                VStack(alignment: .leading) {
                                    Text("Bubbles")
                                        .font(.headline)
                                    Text("Owner Mint • 2w ago")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Patients")
        }
    }
}


private struct QueueView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Waiting", gradient: [Color(hex: "FFE5A0").opacity(0.2), Color.white]) {
                        ForEach(0..<3, id: \.self) { idx in
                            cuteInfoRow(icon: "⏳", title: "Owner #\(idx + 312)", subtitle: "Waiting 3m • Auto-escalate in 12m")
                            if idx < 2 { Divider().padding(.leading, 50) }
                        }
                    }
                    cuteCard("Completed", gradient: [Color(hex: "98D8AA").opacity(0.2), Color.white]) {
                        ForEach(0..<2, id: \.self) { idx in
                            cuteInfoRow(icon: "✅", title: "Case #\(idx + 123)", subtitle: "Resolved successfully")
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Queue")
        }
    }
}

private struct ContentHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Campaigns", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteActionRow(icon: "🎉", title: "Wellness Promo", subtitle: "Edit builder", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteActionRow(icon: "💉", title: "Vaccine Drive", subtitle: "View analytics", showChevron: true)
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Content Hub")
        }
    }
}


private struct VetSettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Doctor Profile", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        cuteInfoRow(icon: "👩‍⚕️", title: "Dr. Siri", subtitle: "Edit details", showChevron: true)
                    }
                    cuteCard("Practice", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        cuteActionRow(icon: "📅", title: "Availability", subtitle: "Manage schedule", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteActionRow(icon: "🏷️", title: "Pricing", subtitle: "Consultation fees", showChevron: true)
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Settings")
        }
    }
}



private func cuteStatusTile(icon: String, title: String, subtitle: String, colors: [Color]) -> some View {
    VStack(spacing: 10) {
        Text(icon).font(.system(size: 28))
        Text(subtitle)
            .font(.title3.bold())
            .foregroundStyle(LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing))
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 18)
    .background(
        ZStack {
            RoundedRectangle(cornerRadius: 22).fill(.white)
            RoundedRectangle(cornerRadius: 22).fill(LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    )
    .overlay(RoundedRectangle(cornerRadius: 22).stroke(colors[0].opacity(0.2), lineWidth: 2))
    .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
}

private func cuteCard<Content: View>(_ title: String, gradient: [Color], @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 18) {
        if !title.isEmpty {
            Text(title).font(.title3.bold()).foregroundStyle(.primary)
        }
        content()
    }
    .padding(22)
    .background(
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(.white)
            RoundedRectangle(cornerRadius: 28).fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    )
    .overlay(RoundedRectangle(cornerRadius: 28).stroke(gradient[0].opacity(0.3), lineWidth: 2))
    .shadow(color: gradient[0].opacity(0.15), radius: 16, y: 8)
}


private func cuteActionRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
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
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(badgeColor, in: Capsule())
                .shadow(color: badgeColor.opacity(0.3), radius: 4, y: 2)
        }
        if showChevron {
            Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
        }
    }
    .padding(.vertical, 6)
}


private func cuteInfoRow(icon: String, title: String, subtitle: String, badge: String? = nil, badgeColor: Color? = nil, showChevron: Bool = false) -> some View {
    HStack(spacing: 14) {
        Text(icon)
            .font(.system(size: 24))
            .frame(width: 40, height: 40)
            .background(Circle().fill(.white).shadow(color: .black.opacity(0.05), radius: 4, y: 2))
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.body.weight(.semibold)).foregroundStyle(.primary)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
        if let badge = badge, let badgeColor = badgeColor {
            Text(badge)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(badgeColor, in: Capsule())
        }
        if showChevron {
            Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
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
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    ContentView()
}

