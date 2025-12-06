import SwiftUI
import MapKit
import PetReadyShared

struct OwnerClinicsView: View {
    @StateObject private var viewModel = OwnerClinicsViewModel()
    @State private var selectedClinic: Clinic?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading nearby clinics…")
                        .padding()
                }

                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.mapPins) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack(spacing: 4) {
                            Image(systemName: pin.isUser ? "location.circle.fill" : "cross.case.fill")
                                .foregroundStyle(pin.isUser ? .blue : .pink)
                                .font(.title2)
                            if let name = pin.title {
                                Text(name)
                                    .font(.caption2.weight(.semibold))
                                    .padding(4)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                        .onTapGesture {
                            selectedClinic = viewModel.clinics.first { $0.id == pin.id }
                        }
                    }
                }
                .frame(height: 260)
                .overlay(alignment: .topTrailing) {
                    VStack(spacing: 8) {
                        Button { viewModel.zoom(delta: 0.5) } label: { mapControl(icon: "plus.magnifyingglass") }
                        Button { viewModel.zoom(delta: -0.5) } label: { mapControl(icon: "minus.magnifyingglass") }
                        Button { Task { await viewModel.refresh() } } label: { mapControl(icon: "gobackward") }
                    }
                    .padding(8)
                }

                List {
                    Section("Nearby clinics (\(viewModel.clinics.count))") {
                        ForEach(viewModel.clinics) { clinic in
                            NavigationLink(value: clinic) {
                                clinicRow(clinic)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationDestination(for: Clinic.self) { clinic in
                ClinicDetailView(
                    clinic: clinic,
                    pets: viewModel.pets,
                    ownerId: viewModel.ownerId
                )
            }
            .navigationTitle("Clinics")
            .task { await viewModel.refresh() }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { newValue in
                if !newValue { viewModel.errorMessage = nil }
            })) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func mapControl(icon: String) -> some View {
        Image(systemName: icon)
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private func clinicRow(_ clinic: Clinic) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(clinic.name).font(.headline)
                Spacer()
                if let distance = clinic.distanceKm {
                    Text(String(format: "%.1f km", distance))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if let specialty = clinic.specialty {
                Text(specialty)
                    .font(.subheadline.weight(.semibold))
            }
            if let rating = clinic.rating {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption.weight(.semibold))
                    if let reviews = clinic.reviewCount {
                        Text("(\(reviews))").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Text(clinic.address)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

final class OwnerClinicsViewModel: ObservableObject {
    @Published var clinics: [Clinic] = []
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018), span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var pets: [Pet] = []

    private let clinicService: ClinicServiceProtocol
    private let locationService: LocationServiceProtocol
    private let petService: PetServiceProtocol
    private let identityStore: OwnerIdentityStore

    var ownerId: UUID { identityStore.ownerId }

    init(
        clinicService: ClinicServiceProtocol = ClinicService.shared,
        locationService: LocationServiceProtocol = LocationService(),
        petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository()),
        identityStore: OwnerIdentityStore = .shared
    ) {
        self.clinicService = clinicService
        self.locationService = locationService
        self.petService = petService
        self.identityStore = identityStore
    }

    var mapPins: [MapPin] {
        let clinicPins = clinics.map {
            MapPin(id: $0.id, coordinate: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude), title: $0.name, isUser: false)
        }
        let user = locationService.latestSnapshot()
        let userPin = MapPin(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: user.coordinate.latitude, longitude: user.coordinate.longitude), title: "You", isUser: true)
        return [userPin] + clinicPins
    }

    func refresh() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        let snapshot = locationService.latestSnapshot()
        await MainActor.run {
            region.center = CLLocationCoordinate2D(latitude: snapshot.coordinate.latitude, longitude: snapshot.coordinate.longitude)
        }
        let results = await clinicService.listNearbyClinics(latitude: snapshot.coordinate.latitude, longitude: snapshot.coordinate.longitude, radiusKm: 20)
        await MainActor.run {
            clinics = results
            isLoading = false
        }
        do {
            let loadedPets = try await petService.loadPets()
            await MainActor.run { self.pets = loadedPets }
        } catch {
            await MainActor.run { self.errorMessage = "Failed to load pets" }
        }
    }

    func zoom(delta: Double) {
        region.span.latitudeDelta = max(0.01, min(0.3, region.span.latitudeDelta - delta * 0.02))
        region.span.longitudeDelta = max(0.01, min(0.3, region.span.longitudeDelta - delta * 0.02))
    }
}

private struct MapPin: Identifiable, Hashable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let isUser: Bool
}

struct ClinicDetailView: View {
    let clinic: Clinic
    let pets: [Pet]
    let ownerId: UUID
    @State private var showBooking = false
    @State private var confirmation: String?
    @State private var announcements: [GovernmentAnnouncement] = []
    @State private var isLoadingAnnouncements = false

    private let announcementService: AnnouncementServiceProtocol = AnnouncementService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: clinic.coordinate.latitude, longitude: clinic.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))), annotationItems: [clinic]) { item in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Text(clinic.name).font(.title2.bold())
                Text(clinic.address).foregroundStyle(.secondary)
                if let specialty = clinic.specialty {
                    Text(specialty).font(.headline)
                }
                if let hours = clinic.operatingHours {
                    Label(hours, systemImage: "clock")
                        .font(.subheadline)
                }
                if let phone = clinic.phone {
                    Label(phone, systemImage: "phone.fill").font(.subheadline)
                }
                if let email = clinic.email {
                    Label(email, systemImage: "envelope.fill").font(.subheadline)
                }
                if let services = clinic.services, !services.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Services").font(.headline)
                        Text(services.joined(separator: " • "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                announcementSection

                Button {
                    showBooking = true
                } label: {
                    Text("Book appointment")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "A0D8F1"), in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                if let confirmation {
                    Text(confirmation)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Clinic")
        .task { await loadAnnouncements() }
        .sheet(isPresented: $showBooking) {
            AppointmentBookingView(clinic: clinic, pets: pets, ownerId: ownerId) { appointment in
                confirmation = "Requested for \(appointment.date.formatted(date: .abbreviated, time: .shortened))"
            }
        }
    }

    private var announcementSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Announcements").font(.headline)
                if isLoadingAnnouncements { ProgressView().scaleEffect(0.7) }
            }
            if announcements.isEmpty {
                Text("No targeted updates from this clinic.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(announcements) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title).font(.subheadline.weight(.semibold))
                        Text(item.content).font(.caption).foregroundStyle(.secondary)
                        Text(item.publishedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(10)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func loadAnnouncements() async {
        await MainActor.run { isLoadingAnnouncements = true }
        let result = await announcementService.fetchAnnouncements(clinicId: clinic.id)
        await MainActor.run {
            announcements = result
            isLoadingAnnouncements = false
        }
    }
}

struct AppointmentBookingView: View {
    @Environment(\.dismiss) private var dismiss

    let clinic: Clinic
    let pets: [Pet]
    let ownerId: UUID
    var onBooked: (Appointment) -> Void

    @State private var date = Date()
    @State private var reason = ""
    @State private var notes = ""
    @State private var selectedPetId: UUID?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let appointmentService: AppointmentServiceProtocol = AppointmentService.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Pet") {
                    if pets.isEmpty {
                        Text("No pets linked. Register a pet to continue.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Pet", selection: $selectedPetId) {
                            ForEach(pets) { pet in
                                Text(pet.name).tag(Optional(pet.id))
                            }
                        }
                    }
                }
                Section("Clinic") {
                    Text(clinic.name)
                    Text(clinic.address).font(.caption).foregroundStyle(.secondary)
                }
                Section("Appointment") {
                    DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Reason", text: $reason, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                    TextField("Notes for clinic", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
                if let successMessage {
                    Text(successMessage).foregroundStyle(.green)
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle("Book appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? "Booking…" : "Submit") { Task { await submit() } }
                        .disabled(isSubmitting || selectedPetId == nil || pets.isEmpty)
                }
            }
            .onAppear { selectedPetId = pets.first?.id }
        }
    }

    private func submit() async {
        guard let petId = selectedPetId else { return }
        await MainActor.run {
            isSubmitting = true
            successMessage = nil
            errorMessage = nil
        }
        let request = AppointmentRequest(
            ownerId: ownerId,
            petId: petId,
            clinicId: clinic.id,
            requestedDate: date,
            reason: reason.isEmpty ? nil : reason,
            notes: notes.isEmpty ? nil : notes
        )
        let appointment = await appointmentService.requestAppointment(request)
        await MainActor.run {
            successMessage = "Request sent. The clinic will confirm soon."
            isSubmitting = false
            onBooked(appointment)
        }
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        await MainActor.run { dismiss() }
    }
}
