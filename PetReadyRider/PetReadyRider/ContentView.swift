//
//  ContentView.swift
//  PetReadyRider
//
//  Created by - Jhongi on 16/11/2568 BE.
//

import SwiftUI

// Shared helpers
private func cardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(title)
            .font(.headline)
        content()
    }
    .padding()
    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
}

private func row(_ title: String, subtitle: String) -> some View {
    HStack {
        VStack(alignment: .leading) {
            Text(title).bold()
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "chevron.right")
            .foregroundStyle(.tertiary)
    }
    .padding(.vertical, 6)
}

private struct RiderDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    stats
                    cardSection(title: "Active Mission") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SOS #123 • Pickup in 8 min").font(.headline)
                            Text("Owner: Mint | Destination: PetWell Siam")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Divider()
                            HStack {
                                Label("Chat enabled", systemImage: "bubble.fill")
                                Spacer()
                                Button("Navigate") {}
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                    cardSection(title: "Available Jobs") {
                        ForEach(0..<3, id: \.self) { idx in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Request #\(idx + 235)")
                                        .font(.headline)
                                    Text("Pickup in 15 min • 6 km")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Accept") {}
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Rider Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Go Online") {}
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ready for dispatch")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Keep acceptance >90% to unlock bonuses.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private var stats: some View {
        HStack(spacing: 12) {
            stat("Acceptance", value: "92%", color: .green)
            stat("Response", value: "2m", color: .orange)
            stat("Rating", value: "4.8", color: .purple)
        }
    }

    private func stat(_ title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

private struct RiderJobsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Available") {
                    ForEach(0..<5, id: \.self) { idx in
                        NavigationLink("Job #\(idx + 300)", destination: Text("Job detail"))
                    }
                }
                Section("Scheduled") {
                    ForEach(0..<2, id: \.self) { idx in
                        Text("Appointment \(idx + 1) • Tomorrow 9:00")
                    }
                }
            }
            .navigationTitle("Jobs")
        }
    }
}

private struct RiderWalletView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                cardSection(title: "Balance") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Payout balance").font(.caption).foregroundStyle(.secondary)
                            Text("฿3,280").font(.title2.bold())
                        }
                        Spacer()
                        Button("Withdraw") {}
                            .buttonStyle(.borderedProminent)
                    }
                }
                cardSection(title: "History") {
                    ForEach(0..<4, id: \.self) { idx in
                        row("Job #\(idx + 210)", subtitle: "Earned ฿320 • Today")
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Wallet")
        }
    }
}

private struct RiderProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Identity") {
                    NavigationLink("Documents", destination: Text("Upload documents"))
                    NavigationLink("Vehicle profile", destination: Text("Vehicle details"))
                }
                Section("Service") {
                    NavigationLink("Service areas", destination: Text("Map coverage"))
                    NavigationLink("Notifications", destination: Text("Alert preferences"))
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            RiderDashboardView()
                .tabItem { Label("Dashboard", systemImage: "rectangle.grid.2x2.fill") }
            RiderJobsView()
                .tabItem { Label("Jobs", systemImage: "list.bullet.clipboard") }
            RiderWalletView()
                .tabItem { Label("Wallet", systemImage: "creditcard.fill") }
            RiderProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    ContentView()
}
