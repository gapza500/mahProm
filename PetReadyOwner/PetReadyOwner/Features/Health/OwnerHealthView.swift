import SwiftUI
import PetReadyShared

struct OwnerHealthView: View {
    @ObservedObject private var identityStore = OwnerIdentityStore.shared
    @StateObject private var viewModel = CareTimelineViewModel(service: CareTimelineService())

    private var upcomingEvents: [CareEvent] {
        viewModel.events
            .filter { $0.status != .completed }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    private var completedEvents: [CareEvent] {
        viewModel.events
            .filter { $0.status == .completed }
            .sorted { $0.scheduledAt > $1.scheduledAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    timelineCard(title: "Upcoming Care", events: upcomingEvents, emptyCopy: "No upcoming care yet. Your vet can add appointments once you’re scheduled.")
                    timelineCard(title: "Recent History", events: completedEvents, emptyCopy: "No records logged. Ask your vet to share treatment notes.")
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Health")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .task { await viewModel.loadEvents(ownerId: identityStore.ownerId) }
        .refreshable { await viewModel.loadEvents(ownerId: identityStore.ownerId) }
        .alert("Health Timeline", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if !newValue { viewModel.errorMessage = nil }
            }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var summaryCard: some View {
        cuteCard("Care Overview", gradient: [Color(hex: "FFF0F5"), Color.white]) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    summaryMetric(title: "Upcoming", value: "\(upcomingEvents.count)")
                    Spacer()
                    summaryMetric(title: "History", value: "\(completedEvents.count)")
                    Spacer()
                    summaryMetric(title: "Pets", value: petCount)
                }
                Text("Care events sync directly with your vet. Tap a pet to see details in the Pets tab.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func timelineCard(title: String, events: [CareEvent], emptyCopy: String) -> some View {
        cuteCard(title, gradient: [Color(hex: "E8F4FF"), Color.white]) {
            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if events.isEmpty {
                Text(emptyCopy)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 14) {
                    ForEach(events) { event in
                        OwnerCareEventRow(event: event)
                        if event.id != events.last?.id {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
        }
    }

    private var petCount: String {
        let uniqueIds = Set(viewModel.events.map { $0.petId })
        return "\(max(1, uniqueIds.count))"
    }
}
