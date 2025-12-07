import SwiftUI
import Combine
import MapKit
import PetReadyShared

struct RiderJobsScreen: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = RiderJobsViewModel(
        service: SOSServiceFactory.make(),
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

                    if viewModel.isCaseAssignedToMe(caseItem) {
                        NavigationLink {
                            RiderNavigationScreen(caseId: caseId, viewModel: viewModel)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            riderCuteCard("Navigation", gradient: [Color(hex: "E8FFE8"), Color(hex: "F2FFF2")]) {
                                HStack(spacing: 12) {
                                    Image(systemName: "map.fill")
                                        .font(.title3)
                                    VStack(alignment: .leading) {
                                        Text("Mission navigation")
                                            .font(.headline)
                                        Text("Open full-screen map to navigate")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
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

struct RiderNavigationScreen: View {
    let caseId: UUID
    @ObservedObject var viewModel: RiderJobsViewModel
    @Environment(\.dismiss) private var dismiss

    private var caseItem: SOSCase? {
        viewModel.cases.first(where: { $0.id == caseId })
    }

    var body: some View {
        Group {
            if let caseItem {
                ZStack(alignment: .bottom) {
                    RiderNavigationMapView(
                        pickup: caseItem.pickup,
                        destination: caseItem.destination,
                        riderLocation: viewModel.currentLocation()
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 16) {
                        RiderNavigationStatusBar(caseItem: caseItem)

                        RiderNavigationActionsView(
                            pickup: caseItem.pickup,
                            destination: caseItem.destination,
                            currentLocation: viewModel.currentLocation()
                        )

                        RiderNavigationStageControls(
                            caseStatus: caseItem.status,
                            startNavigation: {
                                await viewModel.startNavigation(caseId: caseId)
                            },
                            completeNavigation: {
                                await viewModel.complete(caseId: caseId)
                            },
                            onCompleteDismiss: {
                                dismiss()
                            }
                        )
                    }
                    .padding()
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .padding()
                }
                .background(DesignSystem.Colors.appBackground)
                .toolbar(.hidden, for: .navigationBar)
            } else {
                ProgressView("Loading navigation…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DesignSystem.Colors.appBackground)
            }
        }
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

struct RiderNavigationPanel: View {
    let caseItem: SOSCase
    let riderCoordinate: Coordinate?
    let startNavigation: () async -> Void
    let completeNavigation: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            RiderNavigationMapView(
                pickup: caseItem.pickup,
                destination: caseItem.destination,
                riderLocation: riderCoordinate
            )
            RiderNavigationActionsView(
                pickup: caseItem.pickup,
                destination: caseItem.destination,
                currentLocation: riderCoordinate
            )
            Divider()
            RiderNavigationStageControls(
                caseStatus: caseItem.status,
                startNavigation: startNavigation,
                completeNavigation: completeNavigation
            )
        }
    }
}

struct RiderNavigationStageControls: View {
    let caseStatus: SOSStatus
    let startNavigation: () async -> Void
    let completeNavigation: () async -> Void
    var onCompleteDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stageDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            switch caseStatus {
            case .assigned:
                actionButton(title: "Start navigation", color: Color(hex: "A0D8F1")) {
                    await startNavigation()
                }
            case .enRoute:
                actionButton(title: "Complete job", color: Color(hex: "98D8AA")) {
                    await completeNavigation()
                    await MainActor.run { onCompleteDismiss?() }
                }
            case .completed:
                Label("Job completed", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: "98D8AA"))
            default:
                EmptyView()
            }
        }
    }

    private func actionButton(title: String, color: Color, action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(DesignSystem.Colors.onAccentText)
        }
    }

    private var stageDescription: String {
        switch caseStatus {
        case .assigned:
            return "Navigate to the owner's pickup location."
        case .enRoute:
            return "Confirm once you have completed the drop-off."
        case .completed:
            return "Thanks for completing this SOS."
        default:
            return "Accept the job to begin navigation."
        }
    }
}

struct RiderNavigationMapView: View {
    let pickup: Coordinate
    let destination: Coordinate?
    let riderLocation: Coordinate?

    @State private var region: MKCoordinateRegion

    init(pickup: Coordinate, destination: Coordinate?, riderLocation: Coordinate?) {
        self.pickup = pickup
        self.destination = destination
        self.riderLocation = riderLocation
        let center = pickup.clLocationCoordinate
        _region = State(initialValue: MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: pins) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                VStack(spacing: 2) {
                    Text(pin.label)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.85), in: Capsule())
                    Circle()
                        .fill(pin.tint)
                        .frame(width: 12, height: 12)
                        .shadow(radius: 3)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { updateRegion() }
        .onChange(of: riderLocation?.latitude ?? 0) { _ in updateRegion() }
        .onChange(of: destination?.latitude ?? 0) { _ in updateRegion() }
    }

    private var pins: [NavigationPin] {
        var items: [NavigationPin] = [
            NavigationPin(label: "Pickup", tint: .pink, coordinate: pickup.clLocationCoordinate)
        ]
        if let destination {
            items.append(NavigationPin(label: "Clinic", tint: .blue, coordinate: destination.clLocationCoordinate))
        }
        if let riderLocation {
            items.append(NavigationPin(label: "You", tint: .green, coordinate: riderLocation.clLocationCoordinate))
        }
        return items
    }

    private func updateRegion() {
        guard let region = regionThatFits(pins.map(\.coordinate)) else { return }
        self.region = region
    }
}

private struct NavigationPin: Identifiable {
    let id = UUID()
    let label: String
    let tint: Color
    let coordinate: CLLocationCoordinate2D
}

struct RiderNavigationStatusBar: View {
    let caseItem: SOSCase

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(caseItem.status.readableLabel)
                    .font(.headline)
                Text("SOS #\(caseItem.id.uuidString.prefix(6)) • \(caseItem.priority.readableLabel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Pickup")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(caseItem.pickup.latitude, specifier: "%.4f"), \(caseItem.pickup.longitude, specifier: "%.4f")")
                    .font(.caption.weight(.semibold))
                if let destination = caseItem.destination {
                    Text("Drop-off • \(destination.latitude, specifier: "%.4f"), \(destination.longitude, specifier: "%.4f")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct RiderNavigationActionsView: View {
    let pickup: Coordinate
    let destination: Coordinate?
    let currentLocation: Coordinate?

    @Environment(\.openURL) private var openURL
    @State private var mapError: String?
    private let mapsService = MapsService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Navigate with Apple or Google Maps.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                navigationButton(title: "Apple Maps", systemImage: "map.fill") {
                    try mapsService.appleMapsURL(
                        origin: currentLocation?.clLocationCoordinate,
                        destination: pickup.clLocationCoordinate
                    )
                }
                navigationButton(title: "Google Maps", systemImage: "globe.americas.fill") {
                    try mapsService.googleMapsURL(
                        origin: currentLocation?.clLocationCoordinate,
                        destination: pickup.clLocationCoordinate
                    )
                }
            }

            if let destination {
                Text("Drop-off: \(destination.latitude, specifier: "%.4f"), \(destination.longitude, specifier: "%.4f")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .alert("Unable to open Maps", isPresented: Binding(get: { mapError != nil }, set: { _ in mapError = nil })) {
            Button("OK", role: .cancel) { mapError = nil }
        } message: {
            Text(mapError ?? "Please try again.")
        }
    }

    private func navigationButton(title: String, systemImage: String, builder: @escaping () throws -> URL) -> some View {
        Button {
            do {
                openURL(try builder())
            } catch {
                mapError = "Could not create a navigation link."
            }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(hex: "A0D8F1"))
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

extension RiderJobsViewModel {
    func currentLocation() -> Coordinate? {
        let snapshot = locationService.latestSnapshot()
        return Coordinate(latitude: snapshot.coordinate.latitude, longitude: snapshot.coordinate.longitude)
    }

    func isCaseAssignedToMe(_ caseItem: SOSCase) -> Bool {
        caseItem.riderId == riderId
    }

    func startNavigation(caseId: UUID) async {
        do {
            _ = try await service.markEnRoute(id: caseId, riderId: riderId, etaMinutes: nil, distanceKm: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func complete(caseId: UUID) async {
        do {
            _ = try await service.completeCase(id: caseId)
            await WalletStore.shared.recordCompletion(amount: 400)
        } catch {
            errorMessage = error.localizedDescription
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

private extension Coordinate {
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private func regionThatFits(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
    guard let first = coordinates.first else { return nil }
    var minLat = first.latitude
    var maxLat = first.latitude
    var minLon = first.longitude
    var maxLon = first.longitude

    for coordinate in coordinates.dropFirst() {
        minLat = min(minLat, coordinate.latitude)
        maxLat = max(maxLat, coordinate.latitude)
        minLon = min(minLon, coordinate.longitude)
        maxLon = max(maxLon, coordinate.longitude)
    }

    let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLon + maxLon) / 2
    )

    let span = MKCoordinateSpan(
        latitudeDelta: max((maxLat - minLat) * 1.5, 0.01),
        longitudeDelta: max((maxLon - minLon) * 1.5, 0.01)
    )

    return MKCoordinateRegion(center: center, span: span)
}
