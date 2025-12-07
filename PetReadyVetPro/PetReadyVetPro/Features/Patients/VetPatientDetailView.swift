import SwiftUI
import PetReadyShared

struct VetPatientDetailView: View {
    let pet: Pet
    let vetProfile: UserProfile?

    @StateObject private var timelineViewModel = CareTimelineViewModel(service: CareTimelineService())
    @State private var showingComposer = false
    @State private var eventToComplete: CareEvent?
    @State private var completionNotes: String = ""

    private var sortedEvents: [CareEvent] {
        timelineViewModel.events.sorted { $0.scheduledAt > $1.scheduledAt }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard
                timelineSection
            }
            .padding()
        }
        .background(DesignSystem.Colors.appBackground)
        .navigationTitle(pet.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showingComposer = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(pet.ownerId == nil)

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
            set: { newValue in if !newValue { timelineViewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { timelineViewModel.errorMessage = nil }
        } message: {
            Text(timelineViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingComposer) {
            CareEventComposerView(pet: pet, vetProfile: vetProfile) { event in
                Task { await timelineViewModel.addEvent(event) }
            }
        }
        .sheet(item: $eventToComplete) { event in
            CompletionNotesView(event: event, notes: event.outcomeNotes ?? "") { notes in
                Task {
                    await timelineViewModel.updateStatus(for: event, status: .completed, outcomeNotes: notes)
                }
            }
        }
    }

    private var summaryCard: some View {
        vetCuteCard("Profile", gradient: [Color(hex: "FFF4E5"), Color.white]) {
            VStack(alignment: .leading, spacing: 10) {
                infoRow(title: "Species", value: pet.species.rawValue.capitalized)
                if !pet.breed.isEmpty {
                    infoRow(title: "Breed", value: pet.breed)
                }
                infoRow(title: "Sex", value: pet.sex.capitalized)
                if let dob = pet.dob {
                    infoRow(title: "Birthday", value: dob.formatted(date: .abbreviated, time: .omitted))
                }
                if let weight = pet.weight {
                    infoRow(title: "Weight", value: String(format: "%.1f kg", weight))
                }
                infoRow(title: "Status", value: pet.status.capitalized)
                if let ownerId = pet.ownerId {
                    infoRow(title: "Owner ID", value: String(ownerId.uuidString.prefix(8)) + "…")
                } else {
                    infoRow(title: "Owner ID", value: "Unclaimed")
                }
            }
        }
    }

    private var timelineSection: some View {
        vetCuteCard("Care Timeline", gradient: [Color(hex: "E5F5FF"), Color.white]) {
            if timelineViewModel.isLoading && sortedEvents.isEmpty {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if sortedEvents.isEmpty {
                Text("No care events yet. Schedule treatments or follow-ups to keep owners informed.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 16) {
                    ForEach(sortedEvents) { event in
                        VetCareEventRow(event: event) { action in
                            switch action {
                            case .start:
                                Task { await timelineViewModel.updateStatus(for: event, status: .inProgress) }
                            case .complete:
                                eventToComplete = event
                            case .cancel:
                                Task { await timelineViewModel.updateStatus(for: event, status: .cancelled) }
                            }
                        }
                        if event.id != sortedEvents.last?.id {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }
}

private struct CompletionNotesView: View {
    let event: CareEvent
    @Environment(\.dismiss) private var dismiss
    @State private var notesText: String
    let onSave: (String?) -> Void

    init(event: CareEvent, notes: String, onSave: @escaping (String?) -> Void) {
        self.event = event
        self._notesText = State(initialValue: notes)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(event.title)) {
                    TextEditor(text: $notesText)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("Complete care")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notesText)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct CareEventComposerView: View {
    let pet: Pet
    let vetProfile: UserProfile?
    let onSave: (CareEvent) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var type: CareEventType = .checkup
    @State private var title: String = ""
    @State private var scheduledAt: Date = Date()
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    Picker("Type", selection: $type) {
                        ForEach(CareEventType.allCases, id: \.self) { value in
                            Text(value.rawValue.capitalized).tag(value)
                        }
                    }
                    TextField("Title", text: $title)
                    DatePicker("Scheduled", selection: $scheduledAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("New care event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let ownerId = pet.ownerId else {
                            dismiss()
                            return
                        }
                        let event = CareEvent(
                            ownerId: ownerId,
                            petId: pet.id,
                            petName: pet.name,
                            clinicName: nil,
                            vetName: vetProfile?.displayName,
                            type: type,
                            title: title.isEmpty ? defaultTitle(for: type) : title,
                            scheduledAt: scheduledAt,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
                        )
                        onSave(event)
                        dismiss()
                    }
                    .disabled(pet.ownerId == nil)
                }
            }
        }
    }

    private func defaultTitle(for type: CareEventType) -> String {
        switch type {
        case .vaccine: return "Vaccine"
        case .treatment: return "Treatment"
        case .checkup: return "General checkup"
        case .grooming: return "Grooming"
        case .surgery: return "Surgery"
        case .lab: return "Lab work"
        }
    }
}

private struct VetCareEventRow: View {
    enum Action {
        case start
        case complete
        case cancel
    }

    let event: CareEvent
    let onAction: (Action) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                statusBadge
            }
            Text(event.scheduledAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
            }
            if let outcome = event.outcomeNotes, event.status == .completed {
                Text(outcome)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(event.type.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "F0F4FF"), in: Capsule())
                Spacer()
                Menu {
                    if event.status == .scheduled {
                        Button("Start", action: { onAction(.start) })
                        Button("Mark completed", action: { onAction(.complete) })
                        Button("Cancel", role: .destructive, action: { onAction(.cancel) })
                    } else if event.status == .inProgress {
                        Button("Mark completed", action: { onAction(.complete) })
                        Button("Cancel", role: .destructive, action: { onAction(.cancel) })
                    } else if event.status == .completed {
                        Button("Cancel", role: .destructive, action: { onAction(.cancel) })
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusBadge: some View {
        Text(event.status.rawValue.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15), in: Capsule())
            .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch event.status {
        case .scheduled: return Color(hex: "F4A259")
        case .inProgress: return Color(hex: "F9C80E")
        case .completed: return Color(hex: "4CAF50")
        case .cancelled: return Color(hex: "E74C3C")
        }
    }
}
