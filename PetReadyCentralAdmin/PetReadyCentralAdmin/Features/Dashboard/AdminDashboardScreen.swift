import SwiftUI
import Combine
import PetReadyShared

struct AdminDashboardScreen: View {
    @StateObject private var viewModel = AdminDependencies.shared.petListViewModel
    @StateObject private var sosViewModel = AdminSOSMonitorViewModel()
    @State private var didTriggerInitialLoad = false
    @State private var isLoading = true
    @State private var isShowingPetRegistration = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    metrics
                    AdminSOSMonitorView(viewModel: sosViewModel)
                    cuteCard("📢 Announcements", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        cuteRow(icon: "📣", title: "Send announcement", subtitle: "Broadcast to all pet parents", showChevron: true)
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "📅", title: "Scheduled messages", subtitle: "2 announcements tomorrow", badge: "2", badgeColor: Color(hex: "A0D8F1"))
                    }
                    recentPetRegistrations
                }
                .padding()
            }
            .refreshable { await reload() }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Pet Care Central")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingPetRegistration = true
                    } label: {
                        Label("New Pet", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: {
                        HStack(spacing: 6) {
                            Text("📢")
                            Text("Broadcast").font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [Color(hex: "FF9ECD"), Color(hex: "FFB5D8")], startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 8, y: 4)
                    }
                }
            }
            .task {
                await reloadIfNeeded()
                await sosViewModel.start()
            }
            .sheet(isPresented: $isShowingPetRegistration, onDismiss: {
                Task { await reload() }
            }) {
                NavigationStack { AdminPetRegistrationView() }
            }
        }
    }

    private func reloadIfNeeded() async {
        guard !didTriggerInitialLoad else { return }
        didTriggerInitialLoad = true
        await reload()
    }

    private func reload() async {
        isLoading = true
        await viewModel.loadPets()
        isLoading = false
    }

    private var hero: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("🌟").font(.title)
                        Text("National Pet Dashboard")
                            .font(.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.onAccentText)
                    }
                    Text("Keeping all furry friends safe & happy!")
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.95))
                    HStack(spacing: 12) {
                        Label("5min", systemImage: "clock.fill")
                        Text("•")
                        Label("99% happy", systemImage: "heart.fill")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.9))
                    .padding(.top, 4)
                }
                Spacer()
                Text("🐶").font(.system(size: 70))
            }
            .padding(24)
            .background(
                ZStack {
                    LinearGradient(colors: [Color(hex: "FFB5D8"), Color(hex: "A0D8F1")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Circle().fill(.white.opacity(0.15)).frame(width: 200, height: 200).offset(x: 80, y: -60).blur(radius: 50)
                    Circle().fill(.white.opacity(0.1)).frame(width: 150, height: 150).offset(x: -70, y: 40).blur(radius: 40)
                }
            )
            HStack(spacing: 20) {
                ForEach(0..<5) { _ in
                    Text("🐾").font(.caption2).opacity(0.4)
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
        let activeSOS = sosViewModel.cases.filter { $0.status != .completed && $0.status != .cancelled }.count
        HStack(spacing: 14) {
            cuteMetricTile(emoji: "🆘", title: "SOS", value: "\(activeSOS)", subtitle: "Active", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            cuteMetricTile(emoji: "✅", title: "Approvals", value: "8", subtitle: "Waiting", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            cuteMetricTile(emoji: "🔔", title: "Alerts", value: "1", subtitle: "Active", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
        }
    }

    private func cuteMetricTile(emoji: String, title: String, value: String, subtitle: String, colors: [Color]) -> some View {
        VStack(spacing: 12) {
            Text(emoji).font(.system(size: 32))
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 2) {
                Text(subtitle).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text(title).font(.caption2.weight(.medium)).foregroundStyle(.tertiary).textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(.white)
                RoundedRectangle(cornerRadius: 24).fill(
                    LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(colors[0].opacity(0.2), lineWidth: 2))
        .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
    }

    private var recentPetRegistrations: some View {
        cuteCard("🐾 Recent Pet Registrations", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView().tint(Color(hex: "FF9ECD"))
                    Text("Fetching the latest pets…").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.pets.isEmpty {
                VStack(spacing: 8) {
                    Text("🐶").font(.largeTitle)
                    Text("No new registrations yet").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                PetRegistrationsTable(pets: viewModel.pets).padding(.top, 4)
            }
        }
    }
}

struct AdminSOSMonitorView: View {
    @ObservedObject var viewModel: AdminSOSMonitorViewModel

    private var activeCases: [SOSCase] {
        viewModel.cases.filter { $0.status != .completed && $0.status != .cancelled }
    }

    var body: some View {
        cuteCard("🚨 SOS Monitor", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
            HStack(spacing: 12) {
                metric("Active", value: "\(activeCases.count)")
                metric("Assigned", value: "\(activeCases.filter { $0.riderId != nil }.count)")
                metric("Waiting", value: "\(activeCases.filter { $0.riderId == nil }.count)")
            }
            Divider().padding(.leading, 50)
            if activeCases.isEmpty {
                Text("No open SOS cases. Good job! 🎉")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(activeCases.prefix(3)) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🆘")
                            Text(item.incidentType.readableLabel)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(item.status.readableLabel)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DesignSystem.Colors.onAccentText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(hex: "FFB5D8"), in: Capsule())
                        }
                        if let rider = item.riderId {
                            Text("Assigned rider: \(rider.uuidString.prefix(6))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Awaiting rider assignment")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Button {
                                Task { await viewModel.reassign(caseId: item.id) }
                            } label: {
                                Text("Assign / Reassign")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(DesignSystem.Colors.onAccentText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "A0D8F1"), in: Capsule())
                            }
                            Spacer()
                            if let latest = item.events.last {
                                Text(latest.message)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if item.id != activeCases.prefix(3).last?.id {
                        Divider().padding(.leading, 50)
                    }
                }
            }
            Divider().padding(.leading, 50)
            VStack(alignment: .leading, spacing: 8) {
                Text("Live SOS feed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(viewModel.liveEvents.suffix(4)) { event in
                    HStack {
                        Text(event.description)
                            .font(.caption)
                        Spacer()
                        Text(event.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.bold())
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

@MainActor
final class AdminSOSMonitorViewModel: ObservableObject {
    @Published var cases: [SOSCase] = []
    @Published var liveEvents: [LiveEvent] = []

    private let service: SOSServiceProtocol
    private let realtime: RealtimeSyncServiceProtocol
    private var hasStarted = false

    init(service: SOSServiceProtocol = SOSServiceFactory.make(), realtime: RealtimeSyncServiceProtocol = RealtimeSyncService()) {
        self.service = service
        self.realtime = realtime
    }

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        cases = await service.fetchCases()
        service.observeCases { [weak self] cases in
            Task { @MainActor in self?.cases = cases }
        }
        Task {
            let stream = await realtime.subscribe(to: "sos")
            for await event in stream {
                await MainActor.run {
                    self.liveEvents.append(event)
                }
            }
        }
    }

    func reassign(caseId: UUID) async {
        let newRider = UUID()
        _ = try? await service.acceptCase(id: caseId, riderId: newRider)
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
