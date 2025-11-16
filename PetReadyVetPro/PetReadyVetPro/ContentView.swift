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
    }
}

private struct VetDashboard: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                dashboardHero(title: "You’re on a 4.2⭐ response streak", subtitle: "Keep replies under 5 min for verified badge")
                metricRow(items: [
                    ("calendar", "Today", "11 sessions"),
                    ("bolt.fill", "Queue", "3 waiting"),
                    ("star.fill", "Rating", "4.9")
                ])
                cardSection(title: "Consultation Queue") {
                    ForEach(0..<3, id: \.self) { idx in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Owner #\(idx + 241)")
                                    .font(.headline)
                                Text("Fluffy – itchy skin")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Join") {}
                                .buttonStyle(.borderedProminent)
                        }.padding(.vertical, 4)
                    }
                }
                cardSection(title: "Quick Actions") {
                    actionRow(icon: "message.fill", title: "Tele-chat room", detail: "Reply instantly")
                    actionRow(icon: "pills.fill", title: "Send prescription", detail: "Upload photo or PDF")
                    actionRow(icon: "video.fill", title: "Video handoff", detail: "Escalate to voice/video")
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private struct PatientsView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<6, id: \.self) { idx in
                    NavigationLink(destination: Text("Patient detail placeholder")) {
                        VStack(alignment: .leading) {
                            Text("Pet \(idx + 1)").font(.headline)
                            Text("Owner Mint • Latest visit 2w ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Patients")
        }
    }
}

private struct QueueView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Waiting") {
                    ForEach(0..<3, id: \.self) { idx in
                        VStack(alignment: .leading) {
                            Text("Owner #\(idx + 312)")
                                .font(.headline)
                            Text("Waiting 3m • Auto escalate 12m")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Completed") {
                    ForEach(0..<2, id: \.self) { idx in
                        Label("Case \(idx + 123) resolved", systemImage: "checkmark.circle.fill")
                    }
                }
            }
            .navigationTitle("Queue")
        }
    }
}

private struct ContentHubView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Campaigns") {
                    NavigationLink("Wellness Week Promo", destination: Text("Campaign builder"))
                    NavigationLink("Vaccination Drive", destination: Text("Campaign analytics"))
                }
                Section("Education") {
                    Label("Upload article", systemImage: "square.and.pencil")
                    Label("View drafts", systemImage: "doc.richtext")
                }
            }
            .navigationTitle("Content Hub")
        }
    }
}

private struct VetSettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Profile", destination: Text("Edit profile"))
                NavigationLink("Availability", destination: Text("Schedule"))
                NavigationLink("Pricing", destination: Text("Consultation fees"))
            }
            .navigationTitle("Settings")
        }
    }
}

private func dashboardHero(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.85))
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
        LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
        in: RoundedRectangle(cornerRadius: 22)
    )
}

private func metricRow(items: [(String, String, String)]) -> some View {
    HStack(spacing: 12) {
        ForEach(items, id: \.0) { item in
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: item.0)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(item.1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(item.2)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
    }
}

private func cardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(title)
            .font(.headline)
        content()
    }
    .padding()
    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
}

private func actionRow(icon: String, title: String, detail: String) -> some View {
    HStack {
        Image(systemName: icon)
            .foregroundStyle(.white)
            .padding()
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
        VStack(alignment: .leading) {
            Text(title).bold()
            Text(detail).font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
    }
    .padding(.vertical, 4)
}

private func rowWithChevron(title: String, subtitle: String) -> some View {
    HStack {
        VStack(alignment: .leading) {
            Text(title).bold()
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "chevron.right")
            .foregroundStyle(.tertiary)
    }
    .padding(.vertical, 6)
}

#Preview {
    ContentView()
}
