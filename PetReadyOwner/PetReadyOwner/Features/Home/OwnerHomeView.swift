import SwiftUI
import Combine
import PetReadyShared

struct OwnerHomeView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = OwnerHomeViewModel()
    @State private var isShowingBarcodeClaim = false
    @State private var isShowingScanner = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    homeHeroCard
                    statusGrid
                    quickHubCard
                    upcomingCareCard

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Scan Barcode") { isShowingScanner = true }
                        Button("Enter Code Manually") { isShowingBarcodeClaim = true }
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingBarcodeClaim) {
            NavigationStack { BarcodeClaimView() }
        }
        .sheet(isPresented: $isShowingScanner) {
            NavigationStack {
                PetScanPlaceholderView(onPetClaimed: { _ in
                    isShowingScanner = false
                })
            }
        }
        .task {
            await viewModel.refresh(ownerProfile: authService.profile)
        }
        .onChange(of: authService.profile?.id) { _, _ in
            Task { await viewModel.refresh(ownerProfile: authService.profile) }
        }
    }

    private var homeHeroCard: some View {
        let nextDateText: String = {
            if let date = viewModel.nextScheduledDate {
                return viewModel.relativeDaysString(for: date)
            }
            return "No upcoming care"
        }()

        return VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome back, \(viewModel.ownerFirstName)! 👋")
                        .font(.title2.bold())
                        .foregroundStyle(DesignSystem.Colors.onAccentText)

                    Text(viewModel.petSummary)
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.95))

                    HStack(spacing: 12) {
                        Label("\(viewModel.vaccineDueCount) vaccines", systemImage: "syringe.fill")
                        Text("•")
                        Label("Next: \(nextDateText)", systemImage: "calendar")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.9))
                    .padding(.top, 4)
                }
                Spacer()
                Text("🐶")
                    .font(.system(size: 60))
            }
            .padding(24)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "FFB5D8"), Color(hex: "A0D8F1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 180, height: 180)
                        .offset(x: 70, y: -50)
                        .blur(radius: 50)
                }
            )

            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { _ in
                    Text("🐾")
                        .font(.caption2)
                        .opacity(0.4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "FFB5D8").opacity(0.3), radius: 20, y: 10)
    }

    private var statusGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            cuteStatusTile(
                icon: "🐾",
                title: "Pets",
                subtitle: "\(viewModel.pets.count)",
                colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")]
            )
            cuteStatusTile(
                icon: "💉",
                title: "Vaccines due",
                subtitle: "\(viewModel.vaccineDueCount)",
                colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")]
            )
            cuteStatusTile(
                icon: "📅",
                title: "Scheduled care",
                subtitle: "\(viewModel.scheduledCareCount)",
                colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")]
            )
            cuteStatusTile(
                icon: "✅",
                title: "Completed",
                subtitle: "\(viewModel.completedCareCount)",
                colors: [Color(hex: "98D8AA"), Color(hex: "C8EED4")]
            )
        }
    }

    private func cuteStatusTile(icon: String, title: String, subtitle: String, colors: [Color]) -> some View {
        VStack(spacing: 10) {
            Text(icon)
                .font(.system(size: 28))

            Text(subtitle)
                .font(.title3.bold())
                .foregroundStyle(
                    LinearGradient(colors: colors.map { $0.opacity(0.8) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white)

                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(colors: colors.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(colors[0].opacity(0.2), lineWidth: 2)
        )
        .shadow(color: colors[0].opacity(0.15), radius: 12, y: 6)
    }

    private var quickHubCard: some View {
        cuteCard("Quick Actions", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            Button {
                isShowingBarcodeClaim = true
            } label: {
                cuteActionRow(icon: "📱", title: "Register via Barcode", subtitle: "Scan or enter code", showChevron: true)
            }
            Divider().padding(.leading, 50)
            NavigationLink {
                OwnerSOSRequestView()
                    .navigationTitle("Start SOS")
            } label: {
                cuteActionRow(
                    icon: "🆘",
                    title: "Start SOS",
                    subtitle: "Emergency dispatch",
                    badge: "Emergency",
                    badgeColor: Color(hex: "FF9ECD"),
                    showChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var upcomingCareCard: some View {
        cuteCard("Upcoming Care", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
            if viewModel.soonestCareEvents.isEmpty {
                cuteInfoRow(icon: "🗓️", title: "No upcoming care", subtitle: "Schedule a consult to keep pets safe")
            } else {
                ForEach(Array(viewModel.soonestCareEvents.enumerated()), id: \.offset) { index, event in
                    cuteInfoRow(
                        icon: event.type == .vaccine ? "💉" : "🩺",
                        title: event.title,
                        subtitle: "\(event.petName) • \(viewModel.relativeDaysString(for: event.scheduledAt))"
                    )
                    if index != viewModel.soonestCareEvents.count - 1 {
                        Divider().padding(.leading, 50)
                    }
                }
            }
        }
    }

}

struct OwnerSOSRequestView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = OwnerSOSViewModel()

    private var requesterId: UUID {
        if let id = authService.profile?.id, let uuid = UUID(uuidString: id) {
            return uuid
        }
        return UUID()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Where are you?", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.locationSnapshot.title)
                            .font(.headline)
                        Text(viewModel.locationSnapshot.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Lat \(viewModel.locationSnapshot.coordinate.latitude, specifier: "%.4f"), Lng \(viewModel.locationSnapshot.coordinate.longitude, specifier: "%.4f")")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "FF9ECD"))
                    }
                }

                cuteCard("What happened?", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Incident type", selection: $viewModel.incidentType) {
                            ForEach(SOSIncidentType.allCases, id: \.self) { type in
                                Text(type.readableLabel).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Priority", selection: $viewModel.priority) {
                            ForEach(SOSPriority.allCases, id: \.self) { priority in
                                Text(priority.readableLabel).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                cuteCard("Details", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Phone number for rider callbacks", text: $viewModel.contactNumber)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.phonePad)
                        TextField("Describe the incident (optional)", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        Toggle("Attach recent photo (mock)", isOn: $viewModel.includeMockMedia)
                            .tint(Color(hex: "FF9ECD"))
                    }
                }

                if let activeCase = viewModel.activeCase {
                    OwnerSOSConfirmationView(
                        caseItem: activeCase,
                        onCancel: {
                            Task { await viewModel.cancelActiveCase() }
                        },
                        initialCountdown: viewModel.countdownDuration
                    )
                    NavigationLink(
                        destination: OwnerSOSCaseDetailView(caseItem: Binding(
                            get: { viewModel.activeCase },
                            set: { viewModel.activeCase = $0 }
                        )),
                        isActive: $viewModel.navigateToCaseDetail
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                } else {
                    Button {
                        Task { await viewModel.send(requesterId: requesterId, petId: nil) }
                    } label: {
                        HStack {
                            if viewModel.isSending { ProgressView().tint(.white) }
                            Text(viewModel.isSending ? "Sending…" : "Send SOS")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "FF9ECD"), in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                        .shadow(color: Color(hex: "FF9ECD").opacity(0.3), radius: 10, y: 6)
                    }
                    .disabled(viewModel.isSending)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
        }
        .task { viewModel.start() }
    }
}

struct OwnerSOSCaseDetailView: View {
    @Binding var caseItem: SOSCase?

    var body: some View {
        ScrollView {
            if let caseItem {
                VStack(spacing: 16) {
                    cuteCard("Case Status", gradient: [Color(hex: "FFE5EC"), Color(hex: "FFF0F5")]) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status: \(caseItem.status.readableLabel)")
                                .font(.headline)
                            Text("Incident: \(caseItem.incidentType.readableLabel)")
                                .font(.subheadline.weight(.semibold))
                            if let rider = caseItem.riderId {
                                Text("Assigned rider: \(rider.uuidString.prefix(6))")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "A0D8F1"))
                            } else {
                                Text("Waiting for rider assignment")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    cuteCard("Locations", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: "Pickup: %.4f, %.4f", caseItem.pickup.latitude, caseItem.pickup.longitude))
                                .font(.caption.weight(.semibold))
                            if let dest = caseItem.destination {
                                Text(String(format: "Destination: %.4f, %.4f", dest.latitude, dest.longitude))
                                    .font(.caption.weight(.semibold))
                            }
                            if let beacon = caseItem.lastKnownLocation {
                                Text(String(format: "Last beacon: %.4f, %.4f", beacon.latitude, beacon.longitude))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    cuteCard("Event Log", gradient: [Color(hex: "FFF9E5"), Color(hex: "FFFEF0")]) {
                        if caseItem.events.isEmpty {
                            Text("No events yet").font(.caption).foregroundStyle(.secondary)
                        } else {
                            ForEach(caseItem.events.suffix(10)) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.message)
                                        .font(.caption.weight(.semibold))
                                    Text("\(event.actor) • \(event.timestamp.formatted())")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                if event.id != caseItem.events.last?.id {
                                    Divider().padding(.leading, 8)
                                }
                            }
                        }
                    }
                }
                .padding()
            } else {
                Text("SOS case no longer available.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .background(DesignSystem.Colors.appBackground)
        .navigationTitle("SOS Case")
    }
}

struct OwnerSOSConfirmationView: View {
    let caseItem: SOSCase
    let onCancel: () -> Void
    let initialCountdown: Int

    @State private var countdown: Int = 20
    @State private var isCancelling = false
    @State private var countdownActive = true

    private var allowAutoCancel: Bool {
        caseItem.status == .pending || caseItem.status == .awaitingAssignment
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("SOS created", systemImage: "bolt.heart.fill")
                    .font(.headline)
                    .foregroundStyle(DesignSystem.Colors.primaryText)
                Spacer()
                Text(caseItem.status.readableLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DesignSystem.Colors.onAccentText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "FF9ECD"), in: Capsule())
            }
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Incident: \(caseItem.incidentType.readableLabel) • Priority: \(caseItem.priority.readableLabel)")
                    .font(.subheadline.weight(.semibold))
                if let eta = caseItem.etaMinutes {
                    Text("ETA \(eta) minutes").font(.caption).foregroundStyle(.secondary)
                }
                if let rider = caseItem.riderId {
                    Text("Assigned to rider \(rider.uuidString.prefix(6))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "A0D8F1"))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Event log").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                ForEach(caseItem.events.suffix(4)) { event in
                    HStack {
                        Text(event.actor.capitalized)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(hex: "A0D8F1"))
                        Text(event.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }

            HStack {
                if allowAutoCancel {
                    Text("Auto-cancel in \(countdown)s")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    Text("Auto-cancel paused (assigned)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    guard !isCancelling else { return }
                    isCancelling = true
                    onCancel()
                } label: {
                    Text(isCancelling ? "Cancelling…" : "Cancel request")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(DesignSystem.Colors.onAccentText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: "FFE5A0"), in: Capsule())
                }
            }
        }
        .padding()
        .background(DesignSystem.Colors.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "FFB5D8").opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            countdown = initialCountdown
            countdownActive = allowAutoCancel
            tickDown()
        }
        .onChange(of: caseItem.status) { _, _ in
            countdownActive = allowAutoCancel
        }
    }

    private func tickDown() {
        Task {
            while countdown > 0 && !isCancelling && countdownActive && allowAutoCancel {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run { countdown -= 1 }
            }
            if countdown == 0 && !isCancelling && allowAutoCancel {
                onCancel()
            }
        }
    }
}

@MainActor
final class OwnerSOSViewModel: ObservableObject {
    @Published var incidentType: SOSIncidentType = .injury
    @Published var priority: SOSPriority = .urgent
    @Published var notes: String = ""
    @Published var includeMockMedia = false
    @Published var contactNumber: String = ""
    @Published var activeCase: SOSCase?
    @Published var locationSnapshot: LocationSnapshot
    @Published var isSending = false
    @Published var errorMessage: String?
    @Published var countdownDuration: Int = 120
    @Published var navigateToCaseDetail = false

    private let service: SOSServiceProtocol
    private let locationService: LocationServiceProtocol
    private let pushService: PushNotificationServiceProtocol
    private var locationTask: Task<Void, Never>?
    private var hasStarted = false

    init(
        service: SOSServiceProtocol = SOSServiceFactory.make(),
        locationService: LocationServiceProtocol = LocationService(),
        pushService: PushNotificationServiceProtocol = PushNotificationService()
    ) {
        self.service = service
        self.locationService = locationService
        self.pushService = pushService
        self.locationSnapshot = locationService.latestSnapshot()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        locationService.requestAuthorizationIfNeeded()
        listenForLocation()
        listenForCaseUpdates()
    }

    func send(requesterId: UUID, petId: UUID?) async {
        isSending = true
        errorMessage = nil

        let attachments = includeMockMedia ? [URL(string: "https://example.com/mock-sos-photo.jpg")! ] : []
        countdownDuration = countdownSeconds(for: priority)
        let request = SOSRequest(
            requesterId: requesterId,
            petId: petId,
            incidentType: incidentType,
            priority: priority,
            pickup: Coordinate(latitude: locationSnapshot.coordinate.latitude, longitude: locationSnapshot.coordinate.longitude),
            destination: nil,
            contactNumber: contactNumber.isEmpty ? nil : contactNumber,
            notes: notes.isEmpty ? nil : notes,
            attachmentURLs: attachments
        )

        do {
            let created = try await service.createCase(request)
            await MainActor.run {
                self.activeCase = created
                self.isSending = false
                self.navigateToCaseDetail = true
            }
            pushService.scheduleLocalNotification(title: "SOS sent", body: "We’re dispatching help now.", timeInterval: 1)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isSending = false
            }
        }
    }

    func cancelActiveCase() async {
        guard let activeCase else { return }
        _ = try? await service.cancelCase(id: activeCase.id, reason: "Owner cancelled in app")
        pushService.scheduleLocalNotification(title: "SOS cancelled", body: "You can start a new request anytime.", timeInterval: 1)
        await MainActor.run { self.activeCase = nil }
    }

    private func listenForLocation() {
        locationTask?.cancel()
        locationTask = Task {
            for await snapshot in locationService.locationUpdates() {
                await MainActor.run { self.locationSnapshot = snapshot }
            }
        }
    }

    private func listenForCaseUpdates() {
        service.observeCases { [weak self] cases in
            guard let self, let activeId = self.activeCase?.id else { return }
            if let updated = cases.first(where: { $0.id == activeId }) {
                Task { @MainActor in
                    self.activeCase = updated
                    if updated.status == .assigned || updated.status == .enRoute {
                        self.navigateToCaseDetail = true
                    }
                }
            }
        }
    }

    deinit {
        locationTask?.cancel()
    }

    private func countdownSeconds(for priority: SOSPriority) -> Int {
        switch priority {
        case .routine: return 180
        case .urgent: return 120
        case .critical: return 60
        }
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
