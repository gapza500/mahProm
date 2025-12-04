import SwiftUI
import PetReadyShared

struct RiderJobsScreen: View {
    @State private var isShowingFilters = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    riderCuteCard("Available", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<5, id: \.self) { idx in
                            NavigationLink {
                                FeaturePlaceholderView(
                                    title: "Job Detail",
                                    message: "Walkthrough of live tracking, chat entry and navigation from the shared infrastructure services.",
                                    icon: "🛵",
                                    highlights: [
                                        "Route preview from LocationService",
                                        "Realtime updates feed"
                                    ]
                                )
                                .navigationTitle("Job #\(idx + 300)")
                            } label: {
                                riderCuteJobRow(icon: "📦", title: "Job #\(idx + 300)", subtitle: "Standard delivery", showChevron: true)
                            }
                            .buttonStyle(.plain)
                            if idx < 4 { Divider().padding(.leading, 50) }
                        }
                    }
                    riderCuteCard("Scheduled", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        ForEach(0..<2, id: \.self) { idx in
                            NavigationLink {
                                FeaturePlaceholderView(
                                    title: "Upcoming Appointment",
                                    message: "Queue monitor sample view referencing clinic pipelines.",
                                    icon: "📅",
                                    highlights: ["Auto check-in", "Attach vet instructions"]
                                )
                                .navigationTitle("Appointment \(idx + 1)")
                            } label: {
                                riderCuteJobRow(
                                    icon: "📅",
                                    title: "Appointment \(idx + 1)",
                                    subtitle: "Tomorrow 9:00",
                                    badge: "Scheduled",
                                    badgeColor: Color(hex: "FFE5A0"),
                                    showChevron: true
                                )
                            }
                            .buttonStyle(.plain)
                            if idx == 0 { Divider().padding(.leading, 50) }
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingFilters = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFilters) {
            RiderJobFilterView()
        }
    }
}

struct RiderJobFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var includeSOS = true
    @State private var includeStandard = true
    @State private var maxDistance: Double = 8
    @State private var sortOption = 0

    private let mockRoute = LocationService().requestMockRoute()

    var body: some View {
        NavigationStack {
            Form {
                Section("Job Types") {
                    Toggle("SOS missions", isOn: $includeSOS)
                    Toggle("Standard pickups", isOn: $includeStandard)
                }

                Section("Distance") {
                    Slider(value: $maxDistance, in: 2...25, step: 1)
                    Text("Within \(Int(maxDistance)) km radius")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Sort") {
                    Picker("Order", selection: $sortOption) {
                        Text("Nearest first").tag(0)
                        Text("Highest payout").tag(1)
                        Text("Soonest pickup").tag(2)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Live GPS preview") {
                    ForEach(mockRoute) { stop in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stop.title)
                                .font(.subheadline.weight(.semibold))
                            Text(stop.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Powered by the shared LocationService stub so we can wire real data later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Filter Jobs")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { dismiss() }
                }
            }
        }
    }
}
