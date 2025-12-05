import SwiftUI
import Combine
import PetReadyShared

struct RiderJobsScreen: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = RiderJobsViewModel(
        service: SOSService.shared,
        locationService: LocationService()
    )

    private var riderId: UUID {
        if let id = authService.profile?.id, let uuid = UUID(uuidString: id) {
            return uuid
        }
        return UUID()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if let active = viewModel.activeCase {
                        riderCuteCard("Active Mission", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                            RiderJobSummaryView(caseItem: active)
                            HStack {
                                Button {
                                    Task { await viewModel.sendBeacon(caseId: active.id) }
                                } label: {
                                    Label("Send GPS beacon", systemImage: "location.fill")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "FF9ECD"), in: Capsule())
                                }
                                Spacer()
                            }
                        }
                    }

                    riderCuteCard("Available Jobs", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        if viewModel.availableCases.isEmpty {
                            Text("No open SOS cases right now.")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.availableCases) { caseItem in
                                NavigationLink {
                                    RiderJobDetailView(caseId: caseItem.id, viewModel: viewModel)
                                        .navigationTitle("SOS #\(caseItem.id.uuidString.prefix(6))")
                                } label: {
                                    riderCuteJobRow(
                                        icon: "🆘",
                                        title: "\(caseItem.incidentType.readableLabel) • \(caseItem.priority.readableLabel)",
                                        subtitle: formattedSubtitle(for: caseItem),
                                        badge: caseItem.status.readableLabel,
                                        badgeColor: Color(hex: "FF9ECD"),
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                if caseItem.id != viewModel.availableCases.last?.id {
                                    Divider().padding(.leading, 50)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView().tint(Color(hex: "A0D8F1"))
                    } else {
                        Button {
                            Task { await viewModel.reload() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .task { await viewModel.start(riderId: riderId) }
            .refreshable { await viewModel.reload() }
        }
    }

    private func formattedSubtitle(for caseItem: SOSCase) -> String {
        var parts: [String] = []
        if let distance = caseItem.distanceKm {
            parts.append("\(String(format: "%.1f", distance)) km")
        }
        if let eta = caseItem.etaMinutes {
            parts.append("ETA \(eta)m")
        }
        if parts.isEmpty {
            parts.append("Pickup ready")
        }
        return parts.joined(separator: " • ")
    }
}

struct RiderJobDetailView: View {
    let caseId: UUID
    @ObservedObject var viewModel: RiderJobsViewModel

    private var caseItem: SOSCase? {
        viewModel.cases.first(where: { $0.id == caseId })
    }

    var body: some View {
        ScrollView {
            if let caseItem {
                VStack(spacing: 16) {
                    riderCuteCard("Mission Overview", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        RiderJobSummaryView(caseItem: caseItem)
                    }

                    riderCuteCard("Details", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority: \(caseItem.priority.readableLabel)")
                                .font(.subheadline.weight(.semibold))
                            if let notes = caseItem.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text("Pickup: \(caseItem.pickup.latitude, specifier: "%.4f"), \(caseItem.pickup.longitude, specifier: "%.4f")")
                                .font(.caption.weight(.semibold))
                            if let destination = caseItem.destination {
                                Text("Destination: \(destination.latitude, specifier: "%.4f"), \(destination.longitude, specifier: "%.4f")")
                                    .font(.caption.weight(.semibold))
                            }
                        }
                    }

                    riderCuteCard("Event Log", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        ForEach(caseItem.events.suffix(6)) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.caption.weight(.semibold))
                                Text("\(event.actor) • \(event.timestamp.formatted())")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Divider().padding(.leading, 8)
                        }
                    }

                    HStack(spacing: 12) {
                        Button {
                            Task { await viewModel.accept(caseId: caseId) }
                        } label: {
                            Text(caseItem.status == .assigned ? "Reassign to me" : "Accept job")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "A0D8F1"), in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(DesignSystem.Colors.onAccentText)
                        }

                        Button {
                            Task { await viewModel.decline(caseId: caseId) }
                        } label: {
                            Text("Decline")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(DesignSystem.Colors.primaryText)
                        }
                    }

                    Button {
                        Task { await viewModel.sendBeacon(caseId: caseId) }
                    } label: {
                        Label("Send GPS beacon", systemImage: "location.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(DesignSystem.Colors.onAccentText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "FF9ECD"), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding()
            } else {
                Text("Case no longer available.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .background(DesignSystem.Colors.appBackground)
    }
}

struct RiderJobSummaryView: View {
    let caseItem: SOSCase

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🆘")
                    .font(.title3)
                VStack(alignment: .leading) {
                    Text(caseItem.incidentType.readableLabel)
                        .font(.headline)
                    Text(caseItem.priority.readableLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "FF9ECD"))
                }
                Spacer()
                Text(caseItem.status.readableLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DesignSystem.Colors.onAccentText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "A0D8F1"), in: Capsule())
            }
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Pickup: \(caseItem.pickup.latitude, specifier: "%.4f"), \(caseItem.pickup.longitude, specifier: "%.4f")")
                    .font(.caption.weight(.semibold))
                if let dest = caseItem.destination {
                    Text("Destination: \(dest.latitude, specifier: "%.4f"), \(dest.longitude, specifier: "%.4f")")
                        .font(.caption.weight(.semibold))
                }
                if let eta = caseItem.etaMinutes {
                    Text("ETA \(eta) minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

@MainActor
final class RiderJobsViewModel: ObservableObject {
    @Published var cases: [SOSCase] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: SOSServiceProtocol
    private let locationService: LocationServiceProtocol
    private var riderId = UUID()
    private var hasStarted = false

    init(service: SOSServiceProtocol, locationService: LocationServiceProtocol) {
        self.service = service
        self.locationService = locationService
    }

    var availableCases: [SOSCase] {
        cases.filter { $0.status == .pending || $0.status == .awaitingAssignment }
    }

    var activeCase: SOSCase? {
        cases.first { $0.riderId == riderId && $0.status != .completed && $0.status != .cancelled }
    }

    func start(riderId: UUID) async {
        guard !hasStarted else { return }
        hasStarted = true
        self.riderId = riderId
        await reload()
        service.observeCases { [weak self] cases in
            Task { @MainActor in
                self?.cases = cases
            }
        }
    }

    func reload() async {
        isLoading = true
        cases = await service.fetchCases()
        isLoading = false
    }

    func accept(caseId: UUID) async {
        do {
            _ = try await service.acceptCase(id: caseId, riderId: riderId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func decline(caseId: UUID) async {
        await service.declineCase(id: caseId, riderId: riderId)
    }

    func sendBeacon(caseId: UUID) async {
        let snapshot = locationService.latestSnapshot()
        await service.recordBeacon(
            id: caseId,
            coordinate: Coordinate(latitude: snapshot.coordinate.latitude, longitude: snapshot.coordinate.longitude),
            note: "Beacon from rider"
        )
    }
}

private extension SOSIncidentType {
    var readableLabel: String {
        switch self {
        case .injury: return "Injury"
        case .breathing: return "Breathing"
        case .trauma: return "Trauma"
        case .poisoning: return "Poisoning"
        case .heatStroke: return "Heat"
        case .transport: return "Transport"
        case .other: return "Other"
        }
    }
}

private extension SOSPriority {
    var readableLabel: String {
        switch self {
        case .routine: return "Routine"
        case .urgent: return "Urgent"
        case .critical: return "Critical"
        }
    }
}

private extension SOSStatus {
    var readableLabel: String {
        switch self {
        case .pending: return "Pending"
        case .awaitingAssignment: return "Awaiting"
        case .assigned: return "Assigned"
        case .enRoute: return "En route"
        case .arrived: return "Arrived"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .declined: return "Declined"
        }
    }
}
