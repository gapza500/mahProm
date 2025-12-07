import SwiftUI
import PetReadyShared

struct OwnerPetDetailView: View {
    let pet: Pet
    @StateObject private var timelineViewModel = CareTimelineViewModel(service: CareTimelineService())

    private var upcomingEvents: [CareEvent] {
        timelineViewModel.events
            .filter { $0.status != .completed }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    private var historyEvents: [CareEvent] {
        timelineViewModel.events
            .filter { $0.status == .completed }
            .sorted { $0.scheduledAt > $1.scheduledAt }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                petSummary
                timelineSection(title: "Upcoming Care", events: upcomingEvents, emptyCopy: "No upcoming appointments scheduled yet.")
                timelineSection(title: "History", events: historyEvents, emptyCopy: "No care history has been logged for this pet.")
            }
            .padding()
        }
        .background(DesignSystem.Colors.appBackground)
        .navigationTitle(pet.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await timelineViewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(timelineViewModel.isLoading)
            }
        }
        .task { await timelineViewModel.loadEvents(petId: pet.id) }
        .refreshable { await timelineViewModel.loadEvents(petId: pet.id) }
        .alert("Care Timeline", isPresented: Binding(
            get: { timelineViewModel.errorMessage != nil },
            set: { newValue in
                if !newValue { timelineViewModel.errorMessage = nil }
            }
        )) {
            Button("OK", role: .cancel) { timelineViewModel.errorMessage = nil }
        } message: {
            Text(timelineViewModel.errorMessage ?? "")
        }
    }

    private var petSummary: some View {
        cuteCard("Pet Profile", gradient: [Color(hex: "FFF0F5"), Color.white]) {
            VStack(alignment: .leading, spacing: 12) {
                infoRow(label: "Species", value: pet.species.rawValue.capitalized)
                if !pet.breed.isEmpty {
                    infoRow(label: "Breed", value: pet.breed)
                }
                infoRow(label: "Sex", value: pet.sex.capitalized)
                if let dob = pet.dob {
                    infoRow(label: "Birthday", value: dob.formatted(date: .abbreviated, time: .omitted))
                }
                if let weight = pet.weight {
                    infoRow(label: "Weight", value: String(format: "%.1f kg", weight))
                }
                if let barcode = pet.barcodeId {
                    infoRow(label: "Barcode", value: barcode)
                }
                infoRow(label: "Status", value: pet.status.capitalized)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func timelineSection(title: String, events: [CareEvent], emptyCopy: String) -> some View {
        cuteCard(title, gradient: [Color(hex: "E8F4FF"), Color.white]) {
            if timelineViewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if events.isEmpty {
                Text(emptyCopy)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
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

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
    }
}
