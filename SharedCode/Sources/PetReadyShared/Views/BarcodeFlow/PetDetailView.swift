import SwiftUI

public struct PetListRow: View {
    let pet: Pet
    public init(pet: Pet) { self.pet = pet }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(pet.name)
                .font(.headline)
            Text("Species: \(pet.species.rawValue.capitalized)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

public struct BarcodeClaimView: View {
    @State private var codeText: String = ""
    @State private var statusMessage: String?
    @State private var isSaving = false
    private let validator = BarcodeValidator()
    private let service = PetService(repository: PetRepositoryFactory.makeRepository())

    public init() {}

    public var body: some View {
        Form {
            Section("Barcode ID") {
                TextField("PET-XXXX-XXXXXX-XX", text: $codeText)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                Button("Validate & Claim", action: validateAndSave)
                    .disabled(isSaving)
                if isSaving {
                    ProgressView().padding(.vertical, 4)
                }
            }
            if let statusMessage {
                Section("Status") {
                    Text(statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Register via Barcode")
    }

    private func validateAndSave() {
        let trimmed = codeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusMessage = "Enter a code to continue."
            return
        }

        do {
            try validator.validate(trimmed)
            statusMessage = "Code looks valid! Saving…"
            Task {
                await savePet(with: trimmed)
            }
        } catch {
            if let error = error as? LocalizedError, let description = error.errorDescription {
                statusMessage = "Invalid code: \(description)"
            } else {
                statusMessage = "Invalid code: \(error.localizedDescription)"
            }
        }
    }

    @MainActor
    private func savePet(with code: String) async {
        isSaving = true
        defer { isSaving = false }

        let pet = Pet(
            ownerId: UUID(),
            species: [.dog, .cat, .rabbit, .bird, .other].randomElement() ?? .other,
            breed: "",
            name: "Pet \(code.suffix(4))",
            sex: "unknown",
            dob: nil,
            weight: nil,
            barcodeId: code.uppercased(),
            microchipCode: nil,
            status: "pending",
            updatedAt: Date(),
            syncedAt: nil,
            isDirty: false
        )

        do {
            try await service.addPet(pet)
            statusMessage = "Saved! Check Central Admin dashboard for the new registration."
        } catch {
            statusMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
