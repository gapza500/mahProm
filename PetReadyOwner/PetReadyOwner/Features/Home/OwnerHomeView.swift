import SwiftUI
import Combine
import MapKit
import PetReadyShared

struct OwnerHomeView: View {
    @State private var isShowingBarcodeClaim = false
    @State private var isShowingScanner = false
    @StateObject private var appointmentsViewModel = OwnerAppointmentsPreviewViewModel()
    @State private var showCancelToast = false
    @State private var cancelToastMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    homeHeroCard
                    statusGrid
                    quickHubCard
                    upcomingCareCard
                    emergencyCard
                }
                .padding()
            }
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .background(DesignSystem.Colors.appBackground)
            .overlay(alignment: .top) {
                if showCancelToast {
                    toastView(message: cancelToastMessage) { showCancelToast = false }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding()
                }
            }
            .onChange(of: showCancelToast) { _, newValue in
                if newValue {
                    Task {
                        try? await Task.sleep(nanoseconds: 4_000_000_000)
                        await MainActor.run { withAnimation { showCancelToast = false } }
                    }
                }
            }
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
            NavigationStack { PetScanPlaceholderView() }
        }
        .task { await appointmentsViewModel.reload() }
    }

    private func toastView(message: String, dismiss: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SOS update").font(.caption.weight(.bold))
                Text(message)
                    .font(.caption)
            }
            Spacer()
            Button("New SOS") {
                dismiss()
            }
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "FF9ECD"), in: Capsule())
            .foregroundStyle(.white)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 6, y: 4)
    }

    private var homeHeroCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome back! 👋")
                        .font(.title2.bold())
                        .foregroundStyle(DesignSystem.Colors.onAccentText)

                    Text("Fluffy & Basil are safe today")
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.Colors.onAccentText.opacity(0.95))

                    HStack(spacing: 12) {
                        Label("2 vaccines", systemImage: "syringe.fill")
                        Text("•")
                        Label("Next: 7 days", systemImage: "calendar")
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

            HStack(spacing: 16) {
                Spacer()
                Text("🐾")
                    .font(.caption2)
                    .opacity(0.4)
                Text("🐾")
                    .font(.caption2)
                    .opacity(0.4)
                Text("🐾")
                    .font(.caption2)
                    .opacity(0.4)
                Spacer()
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
            cuteStatusTile(icon: "🐾", title: "Pets", subtitle: "3 active", colors: [Color(hex: "FFB5D8"), Color(hex: "FFD4E8")])
            cuteStatusTile(icon: "⏱️", title: "Chat", subtitle: "<5 min", colors: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")])
            cuteStatusTile(icon: "💉", title: "Vaccines", subtitle: "2 soon", colors: [Color(hex: "A0D8F1"), Color(hex: "D4EDFF")])
            cuteStatusTile(icon: "📍", title: "Nearby", subtitle: "1.2 km", colors: [Color(hex: "98D8AA"), Color(hex: "C8EED4")])
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
                HealthQRView()
                    .navigationTitle("Health QR")
            } label: {
                cuteActionRow(icon: "📋", title: "Issue Health QR", subtitle: "Share vaccine proof", showChevron: true)
            }
            .buttonStyle(.plain)
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
            if appointmentsViewModel.upcomingAppointments.isEmpty {
                Text("No appointments yet. Book a clinic visit to see it here.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(appointmentsViewModel.upcomingAppointments.prefix(2)) { appointment in
                    cuteInfoRow(
                        icon: "🩺",
                        title: appointment.reason ?? "Clinic appointment",
                        subtitle: appointment.date.formatted(date: .abbreviated, time: .shortened),
                        badge: appointment.status.readableLabel,
                        badgeColor: Color(hex: "A0D8F1")
                    )
                    if appointment.id != appointmentsViewModel.upcomingAppointments.prefix(2).last?.id {
                        Divider().padding(.leading, 50)
                    }
                }
            }
        }
    }

    private var emergencyCard: some View {
        cuteCard("Emergency Toolkit", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            cuteInfoRow(icon: "✅", title: "SOS profile", subtitle: "Up to date")
            Divider().padding(.leading, 50)
        cuteInfoRow(icon: "🏥", title: "Nearest clinic", subtitle: "PetWell Siam")
        }
    }
}

@MainActor
final class OwnerAppointmentsPreviewViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []

    private let appointmentService: AppointmentServiceProtocol
    private let identityStore: OwnerIdentityStore

    init(
        appointmentService: AppointmentServiceProtocol = AppointmentService.shared,
        identityStore: OwnerIdentityStore = .shared
    ) {
        self.appointmentService = appointmentService
        self.identityStore = identityStore
    }

    var upcomingAppointments: [Appointment] {
        appointments.filter { $0.date >= Date() }.sorted { $0.date < $1.date }
    }

    func reload() async {
        appointments = await appointmentService.fetchAppointments(ownerId: identityStore.ownerId)
    }
}

struct OwnerSOSRequestView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = OwnerSOSViewModel()
    // Dedicated toast state for this screen (Home already has its own)
    @State private var sosShowCancelToast = false
    @State private var sosCancelToastMessage = ""

    private var requesterId: UUID {
        if let id = authService.profile?.id, let uuid = UUID(uuidString: id) {
            return uuid
        }
        return UUID()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    formSection(title: "Where are you?") {
                        Text(viewModel.locationSnapshot.title)
                            .font(.headline)
                        Text(viewModel.locationSnapshot.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Lat \(viewModel.locationSnapshot.coordinate.latitude, specifier: "%.4f"), Lng \(viewModel.locationSnapshot.coordinate.longitude, specifier: "%.4f")")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "FF9ECD"))
                        SOSTrackMapView(
                            pickup: Coordinate(latitude: viewModel.locationSnapshot.coordinate.latitude, longitude: viewModel.locationSnapshot.coordinate.longitude),
                            destination: viewModel.destination ?? Coordinate(latitude: viewModel.locationSnapshot.coordinate.latitude, longitude: viewModel.locationSnapshot.coordinate.longitude),
                            riderLocation: nil
                        )
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text("Location near PetWell Siam")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    formSection(title: "What happened?") {
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

                    formSection(title: "Details") {
                        TextField("Phone number for rider callbacks", text: $viewModel.contactNumber)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.phonePad)
                        TextField("Destination (clinic or home)", text: $viewModel.destinationAddress)
                            .textInputAutocapitalization(.words)
                        TextField("Describe the incident (optional)", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                        Toggle("Attach recent photo (mock)", isOn: $viewModel.includeMockMedia)
                            .tint(Color(hex: "FF9ECD"))
                    }

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

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding()
            .background(DesignSystem.Colors.appBackground)
        }
        .overlay(alignment: .top) {
            if sosShowCancelToast {
                toastView(message: sosCancelToastMessage, dismiss: { sosShowCancelToast = false })
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding()
            }
        }
        .onChange(of: sosShowCancelToast) { _, newValue in
            if newValue {
                Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    await MainActor.run { withAnimation { sosShowCancelToast = false } }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showLiveMap) {
            if let activeCase = viewModel.activeCase {
                OwnerSOSLiveMapView(caseItem: activeCase) {
                    viewModel.showLiveMap = false
                }
            } else {
                Button("Close") { viewModel.showLiveMap = false }
                    .padding()
            }
        }
        .task { viewModel.start() }
    }

    private func formSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private var toastView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SOS update").font(.caption.weight(.bold))
                Text(cancelToastMessage)
                    .font(.caption)
            }
            Spacer()
            Button("New SOS") {
                showCancelToast = false
            }
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "FF9ECD"), in: Capsule())
            .foregroundStyle(.white)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 6, y: 4)
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
                        SOSTrackMapView(
                            pickup: caseItem.pickup,
                            destination: caseItem.destination,
                            riderLocation: caseItem.lastKnownLocation
                        )
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                if let distance = caseItem.distanceKm {
                    Text(String(format: "Rider is %.1f km away", distance))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let rider = caseItem.riderId {
                    Text("Assigned to rider \(rider.uuidString.prefix(6))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "A0D8F1"))
                }
            }

            progressTimeline(status: caseItem.status)

            SOSTrackMapView(
                pickup: caseItem.pickup,
                destination: caseItem.destination,
                riderLocation: caseItem.lastKnownLocation
            )
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))

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

    private func progressTimeline(status: SOSStatus) -> some View {
        let steps: [(SOSStatus, String)] = [
            (.pending, "Requested"),
            (.assigned, "Assigned"),
            (.enRoute, "Rider en route"),
            (.arrived, "Arrived")
        ]
        return HStack {
            ForEach(steps.indices, id: \.self) { idx in
                let step = steps[idx]
                let isDone = statusOrder(status) >= statusOrder(step.0)
                VStack {
                    Circle()
                        .fill(isDone ? Color(hex: "A0D8F1") : Color(.systemGray5))
                        .frame(width: 12, height: 12)
                    Text(step.1)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(isDone ? DesignSystem.Colors.primaryText : .secondary)
                }
                if idx < steps.count - 1 {
                    Rectangle()
                        .fill(isDone ? Color(hex: "A0D8F1") : Color(.systemGray5))
                        .frame(width: 30, height: 2)
                }
            }
        }
    }

    private func statusOrder(_ status: SOSStatus) -> Int {
        switch status {
        case .pending, .awaitingAssignment: return 0
        case .assigned: return 1
        case .enRoute: return 2
        case .arrived: return 3
        case .completed: return 4
        case .declined, .cancelled: return -1
        }
    }
}

private struct SOSTrackPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let tint: Color
    let label: String
}

struct SOSTrackMapView: View {
    let pickup: Coordinate
    let destination: Coordinate?
    let riderLocation: Coordinate?

    @State private var region: MKCoordinateRegion

    init(pickup: Coordinate, destination: Coordinate?, riderLocation: Coordinate?) {
        self.pickup = pickup
        self.destination = destination
        self.riderLocation = riderLocation
        let coords = [pickup] + [destination].compactMap { $0 } + [riderLocation].compactMap { $0 }
        let centerCoord = coords.first ?? pickup
        let center = CLLocationCoordinate2D(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
        _region = State(initialValue: MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(coordinateRegion: $region, annotationItems: pins) { pin in
                MapMarker(coordinate: pin.coordinate, tint: pin.tint)
            }
            .gesture(MagnificationGesture().onChanged { value in
                let delta = 1 / value
                region.span.latitudeDelta = max(0.002, min(0.5, region.span.latitudeDelta * delta))
                region.span.longitudeDelta = max(0.002, min(0.5, region.span.longitudeDelta * delta))
            })

            VStack(alignment: .leading, spacing: 6) {
                if riderLocation != nil { legend(color: .blue, text: "Rider") }
                legend(color: .green, text: "Pickup")
                if destination != nil { legend(color: .pink, text: "Destination") }
                HStack(spacing: 8) {
                    Button { focusAll() } label: {
                        labelButton(system: "dot.viewfinder", title: "Fit")
                    }
                    Button { zoom(step: -0.5) } label: {
                        labelButton(system: "plus.magnifyingglass", title: "In")
                    }
                    Button { zoom(step: 0.5) } label: {
                        labelButton(system: "minus.magnifyingglass", title: "Out")
                    }
                }
                HStack(spacing: 8) {
                    Button { focus(on: pickup) } label: { labelButton(system: "mappin", title: "Pickup") }
                    if let riderLocation {
                        Button { focus(on: riderLocation) } label: { labelButton(system: "figure.walk", title: "Rider") }
                    }
                    if let destination {
                        Button { focus(on: destination) } label: { labelButton(system: "flag", title: "Dest") }
                    }
                }
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .padding(8)
        }
    }

    private func legend(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(text).font(.caption2)
        }
    }

    private var pins: [SOSTrackPin] {
        var items: [SOSTrackPin] = [
            SOSTrackPin(
                coordinate: CLLocationCoordinate2D(latitude: pickup.latitude, longitude: pickup.longitude),
                tint: .green,
                label: "Pickup"
            )
        ]
        if let destination {
            items.append(
                SOSTrackPin(
                    coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude),
                    tint: .pink,
                    label: "Destination"
                )
            )
        }
        if let rider = riderLocation {
            items.append(
                SOSTrackPin(
                    coordinate: CLLocationCoordinate2D(latitude: rider.latitude, longitude: rider.longitude),
                    tint: .blue,
                    label: "Rider"
                )
            )
        }
        return items
    }

    private func labelButton(system: String, title: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: system)
            Text(title).font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
    }

    private func focus(on coordinate: Coordinate) {
        withAnimation {
            region.center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        }
    }

    private func focusAll() {
        let coords = pins.map { $0.coordinate }
        guard !coords.isEmpty else { return }
        let lats = coords.map(\.latitude)
        let lngs = coords.map(\.longitude)
        let minLat = lats.min() ?? region.center.latitude
        let maxLat = lats.max() ?? region.center.latitude
        let minLng = lngs.min() ?? region.center.longitude
        let maxLng = lngs.max() ?? region.center.longitude
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max(0.01, (maxLat - minLat) * 1.4), longitudeDelta: max(0.01, (maxLng - minLng) * 1.4))
        withAnimation { region = MKCoordinateRegion(center: center, span: span) }
    }

    private func zoom(step: Double) {
        let factor = pow(2, step)
        withAnimation {
            region.span.latitudeDelta = max(0.002, min(1.0, region.span.latitudeDelta / factor))
            region.span.longitudeDelta = max(0.002, min(1.0, region.span.longitudeDelta / factor))
        }
    }
}

struct OwnerSOSLiveMapView: View {
    let caseItem: SOSCase
    let onClose: () -> Void

    @State private var sheetOffset: CGFloat = 0
    private let collapsed: CGFloat = 200
    private let expanded: CGFloat = 520

    var body: some View {
        ZStack(alignment: .bottom) {
            SOSTrackMapView(
                pickup: caseItem.pickup,
                destination: caseItem.destination,
                riderLocation: caseItem.lastKnownLocation
            )
            .ignoresSafeArea()

            VStack {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 40, height: 6)
                    .padding(.top, 8)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("SOS #\(caseItem.id.uuidString.prefix(6))")
                            .font(.headline)
                        Spacer()
                        Button("Close") { onClose() }
                            .font(.caption.weight(.bold))
                    }
                    Text("\(caseItem.incidentType.readableLabel) • \(caseItem.priority.readableLabel)")
                        .font(.subheadline.weight(.semibold))
                    if let rider = caseItem.riderId {
                        Text("Rider: \(rider.uuidString.prefix(6))").font(.caption.weight(.bold))
                    } else {
                        Text("Waiting for rider assignment").font(.caption).foregroundStyle(.secondary)
                    }
                    if let eta = caseItem.etaMinutes {
                        Text("ETA \(eta) min • \(String(format: "%.1f", caseItem.distanceKm ?? 0)) km away")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    Text("Events").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    ForEach(caseItem.events.suffix(5)) { event in
                        HStack {
                            Text(event.message).font(.caption)
                            Spacer()
                            Text(event.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .offset(y: sheetOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sheetOffset = min(0, max(collapsed - expanded, sheetOffset + value.translation.height))
                    }
                    .onEnded { value in
                        let midpoint = (collapsed - expanded) / 2
                        withAnimation(.spring()) {
                            sheetOffset = (sheetOffset < midpoint) ? (collapsed - expanded) : 0
                        }
                    }
            )
            .onAppear {
                sheetOffset = 0
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
    @Published var destinationAddress: String = "PetWell Siam Clinic"
    @Published var destination: Coordinate?
    @Published var activeCase: SOSCase?
    @Published var locationSnapshot: LocationSnapshot
    @Published var isSending = false
    @Published var errorMessage: String?
    @Published var countdownDuration: Int = 120
    @Published var navigateToCaseDetail = false
    @Published var showLiveMap = false
    private var lastStatus: SOSStatus?

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
        let destCoordinate = destination ?? Coordinate(latitude: locationSnapshot.coordinate.latitude, longitude: locationSnapshot.coordinate.longitude)
        let request = SOSRequest(
            requesterId: requesterId,
            petId: petId,
            incidentType: incidentType,
            priority: priority,
            pickup: Coordinate(latitude: locationSnapshot.coordinate.latitude, longitude: locationSnapshot.coordinate.longitude),
            destination: destinationAddress.isEmpty ? nil : destCoordinate,
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
                self.lastStatus = created.status
                self.showLiveMap = true
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
                    if let last = self.lastStatus, last != updated.status {
                        let title = "SOS update"
                        let body: String
                        switch updated.status {
                        case .assigned: body = "A rider has been assigned."
                        case .enRoute: body = "Rider is en route."
                        case .arrived: body = "Rider has arrived."
                        case .cancelled: body = "SOS cancelled."
                        case .completed: body = "SOS completed."
                        default: body = "Status changed."
                        }
                        self.pushService.scheduleLocalNotification(title: title, body: body, timeInterval: 1)
                    }
                    self.lastStatus = updated.status
                    self.activeCase = updated
                    if updated.status == .assigned || updated.status == .enRoute {
                        self.navigateToCaseDetail = true
                    }
                    if self.showLiveMap == false {
                        self.showLiveMap = true
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
