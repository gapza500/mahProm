import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AdminDashboardView()
                .tabItem { Label("Dashboard", systemImage: "rectangle.grid.2x2.fill") }
            ApprovalsView()
                .tabItem { Label("Approvals", systemImage: "checkmark.seal.fill") }
            AnnouncementsView()
                .tabItem { Label("Alerts", systemImage: "megaphone.fill") }
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
            AdminSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

private struct AdminDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    metrics
                    card("Live Operations") {
                        row(icon: "exclamationmark.triangle.fill", title: "SOS cases", subtitle: "2 active • 6 resolved today")
                        row(icon: "waveform.path.ecg", title: "Online staff", subtitle: "Vets 45 • Riders 28")
                        row(icon: "bell.badge.fill", title: "Alerts", subtitle: "Heat warning active in Bangkok")
                    }
                    card("Announcements") {
                        row(icon: "megaphone.fill", title: "Create public alert", subtitle: "Broadcast to all apps")
                        row(icon: "calendar.badge.clock", title: "Scheduled posts", subtitle: "2 going out tomorrow")
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Central Admin")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Broadcast") {}
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("National dashboard")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Keep response time under 5m for SOS readiness.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var metrics: some View {
        HStack(spacing: 12) {
            metricTile("SOS", value: "2 Live", color: .orange)
            metricTile("Approvals", value: "8 Pending", color: .blue)
            metricTile("Alerts", value: "1 Active", color: .pink)
        }
    }

    private func metricTile(_ title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

private struct ApprovalsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Vet approvals") {
                    ForEach(0..<3, id: \.self) { idx in
                        rowLabel("Dr. Applicants #\(idx + 41)", subtitle: "License pending verification")
                    }
                }
                Section("Rider registrations") {
                    ForEach(0..<5, id: \.self) { idx in
                        rowLabel("Rider #\(idx + 120)", subtitle: "Documents uploaded")
                    }
                }
            }
            .navigationTitle("Approvals")
        }
    }
}

private struct AnnouncementsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Active") {
                    rowLabel("Heat warning: Bangkok", subtitle: "Broadcast to Owner + Vet apps")
                }
                Section("Drafts") {
                    rowLabel("Pet flu advisory", subtitle: "Scheduled • Tomorrow 09:00")
                    rowLabel("Public holiday notice", subtitle: "Needs approval")
                }
            }
            .navigationTitle("Alerts")
        }
    }
}

private struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    card("System Health") {
                        row(icon: "gauge", title: "Uptime", subtitle: "99.9% last 24h")
                        row(icon: "timer", title: "Chat SLA", subtitle: "Average 7m response")
                        row(icon: "chart.line.uptrend.xyaxis", title: "Usage", subtitle: "+18% weekly sessions")
                    }
                    card("Regional Load") {
                        row(icon: "map.fill", title: "Bangkok", subtitle: "45% of traffic")
                        row(icon: "map.fill", title: "Chiang Mai", subtitle: "22% of traffic")
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Analytics")
        }
    }
}

private struct AdminSettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("System") {
                    NavigationLink("Feature flags", destination: Text("Toggle features"))
                    NavigationLink("Regions", destination: Text("Manage coverage"))
                }
                Section("Team") {
                    NavigationLink("Admin members", destination: Text("Manage team"))
                    NavigationLink("Notifications", destination: Text("Alert preferences"))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Shared UI helpers
private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(title).font(.headline)
        content()
    }
    .padding()
    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
}

private func row(icon: String, title: String, subtitle: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
        Image(systemName: icon)
            .font(.title3)
            .foregroundStyle(Color.accentColor)
            .frame(width: 32, height: 32)
        VStack(alignment: .leading, spacing: 4) {
            Text(title).bold()
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        Spacer()
    }
    .padding(.vertical, 6)
}

private func rowLabel(_ title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title).bold()
        Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
}

#Preview {
    ContentView()
}
