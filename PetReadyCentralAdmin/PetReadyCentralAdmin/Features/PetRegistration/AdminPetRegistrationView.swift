import SwiftUI
import Combine
import PetReadyShared
#if canImport(UIKit)
import UIKit
#endif

final class AdminPetRegistrationViewModel: ObservableObject {
    @Published var ownerIdText: String = ""
    @Published var petName: String = ""
    @Published var species: Pet.Species = .dog
    @Published var breed: String = ""
    @Published var sex: String = "Unknown"
    @Published var dob: Date = Date()
    @Published var hasDOB = false
    @Published var weightText: String = ""
    @Published var barcode: String?
    @Published var isSaving = false
    @Published var statusMessage: String?

    private let petService: PetServiceProtocol
    private let barcodeGenerator = BarcodeGenerator()
    private let barcodeService = BarcodeService()

    init(petService: PetServiceProtocol = PetService(repository: PetRepositoryFactory.makeRepository())) {
        self.petService = petService
    }

    func generateBarcode() {
        do {
            let code = try barcodeGenerator.generate(for: species)
            barcode = code
            statusMessage = "Generated barcode \(code)"
        } catch {
            statusMessage = "Failed to generate barcode. Please try again."
        }
    }

    func savePet() async {
        guard let ownerUuid = UUID(uuidString: ownerIdText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            await MainActor.run { statusMessage = "Owner ID must be a valid UUID." }
            return
        }
        guard !petName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run { statusMessage = "Enter the pet name." }
            return
        }
        guard let barcode else {
            await MainActor.run { statusMessage = "Generate a barcode before saving." }
            return
        }

        let weight = Double(weightText.replacingOccurrences(of: ",", with: "."))

        var pet = Pet(
            ownerId: ownerUuid,
            species: species,
            breed: breed,
            name: petName,
            sex: sex.lowercased(),
            dob: hasDOB ? dob : nil,
            weight: weight,
            barcodeId: barcode,
            microchipCode: nil,
            status: "pending",
            updatedAt: Date(),
            syncedAt: nil,
            isDirty: false
        )

        await MainActor.run { isSaving = true }
        do {
            try await petService.addPet(pet)
            _ = try barcodeService.claim(code: barcode, for: pet)
            await MainActor.run {
                statusMessage = "Pet registration saved. Share barcode \(barcode) with the owner."
                isSaving = false
            }
        } catch {
            await MainActor.run {
                statusMessage = "Failed to save: \(error.localizedDescription)"
                isSaving = false
            }
        }
    }
}

struct AdminPetRegistrationView: View {
    @StateObject private var viewModel = AdminPetRegistrationViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Owner") {
                TextField("Owner UUID", text: $viewModel.ownerIdText)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                Text("Ask the owner to open Settings → Profile to copy their ID.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Pet details") {
                TextField("Pet name", text: $viewModel.petName)
                Picker("Species", selection: $viewModel.species) {
                    Text("Dog").tag(Pet.Species.dog)
                    Text("Cat").tag(Pet.Species.cat)
                    Text("Rabbit").tag(Pet.Species.rabbit)
                    Text("Bird / Other").tag(Pet.Species.bird)
                    Text("Other").tag(Pet.Species.other)
                }
                TextField("Breed (optional)", text: $viewModel.breed)
                Picker("Sex", selection: $viewModel.sex) {
                    Text("Unknown").tag("Unknown")
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                Toggle("Include birthday", isOn: $viewModel.hasDOB.animation())
                if viewModel.hasDOB {
                    DatePicker("Date of birth", selection: $viewModel.dob, displayedComponents: .date)
                }
                TextField("Weight (kg)", text: $viewModel.weightText)
                    .keyboardType(.decimalPad)
            }

            if let barcode = viewModel.barcode {
                Section("Barcode") {
                    HStack {
                        Text(barcode).font(.callout.monospaced())
                        Spacer()
#if canImport(UIKit)
                        Button("Copy") {
                            UIPasteboard.general.string = barcode
                        }
#endif
                    }
#if canImport(UIKit)
                    if let qrImage = try? QRService().generateImage(from: barcode) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 160, height: 160)
                            .padding(.top, 8)
                    }
#endif
                }
            }

            if let status = viewModel.statusMessage {
                Section("Status") {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Generate Barcode") {
                    viewModel.generateBarcode()
                }
                Button {
                    Task { await viewModel.savePet() }
                } label: {
                    HStack {
                        if viewModel.isSaving { ProgressView().tint(.white) }
                        Text(viewModel.isSaving ? "Saving…" : "Save & Issue")
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .navigationTitle("New Pet Registration")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }
}
