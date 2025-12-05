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
    @StateObject private var viewModel: BarcodeClaimViewModel

    public init(
        service: PetServiceProtocol? = nil,
        identityStore: OwnerIdentityStore = .shared,
        onPetClaimed: ((Pet) -> Void)? = nil
    ) {
        let resolvedService = service ?? PetService(repository: PetRepositoryFactory.makeRepository())
        _viewModel = StateObject(
            wrappedValue: BarcodeClaimViewModel(
                service: resolvedService,
                identityStore: identityStore,
                onClaimed: onPetClaimed
            )
        )
    }

    public var body: some View {
        Form {
            Section("Barcode ID") {
                TextField("PET-XXXX-XXXXXX-XX", text: $viewModel.codeText)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                Button("Validate & Claim", action: viewModel.validateAndClaim)
                    .disabled(viewModel.isSaving)
                if viewModel.isSaving {
                    ProgressView().padding(.vertical, 4)
                }
            }
            if let pet = viewModel.claimedPet {
                Section("Linked Pet") {
                    LabeledContent("Name", value: pet.name)
                    LabeledContent("Species", value: pet.species.rawValue.capitalized)
                    if let barcode = pet.barcodeId {
                        LabeledContent("Barcode", value: barcode)
                    }
                    if let ownerId = pet.ownerId {
                        LabeledContent("Owner UUID", value: ownerId.uuidString)
                    }
                    LabeledContent("Status", value: formattedStatus(pet.status))
                }
            }
            if let statusMessage = viewModel.statusMessage {
                Section("Status") {
                    Text(statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Register via Barcode")
    }

}

@MainActor
public final class BarcodeClaimViewModel: ObservableObject {
    @Published var codeText: String = ""
    @Published var statusMessage: String?
    @Published var isSaving = false
    @Published var claimedPet: Pet?

    private let validator = BarcodeValidator()
    private let service: PetServiceProtocol
    private let identityStore: OwnerIdentityStore
    private let onClaimed: ((Pet) -> Void)?

    public init(
        service: PetServiceProtocol,
        identityStore: OwnerIdentityStore,
        onClaimed: ((Pet) -> Void)? = nil
    ) {
        self.service = service
        self.identityStore = identityStore
        self.onClaimed = onClaimed
    }

    func validateAndClaim() {
        let trimmed = codeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusMessage = "Enter a code to continue."
            return
        }

        do {
            try validator.validate(trimmed)
            statusMessage = "Code looks valid! Linking to your pets…"
            Task { await claimPet(with: trimmed.uppercased()) }
        } catch {
            if let error = error as? LocalizedError, let description = error.errorDescription {
                statusMessage = "Invalid code: \(description)"
            } else {
                statusMessage = "Invalid code: \(error.localizedDescription)"
            }
        }
    }

    private func claimPet(with code: String) async {
        isSaving = true
        claimedPet = nil
        defer { isSaving = false }

        do {
            let ownerId = identityStore.ownerId
            let updatedPet = try await service.claimPet(withBarcode: code, ownerId: ownerId)
            claimedPet = updatedPet
            statusMessage = "Success! \(updatedPet.name) is now linked to your account."
            onClaimed?(updatedPet)
        } catch {
            if let localized = error as? LocalizedError,
               let description = localized.errorDescription {
                statusMessage = description
            } else {
                statusMessage = error.localizedDescription
            }
        }
    }
}

private func formattedStatus(_ status: String) -> String {
    status.replacingOccurrences(of: "_", with: " ").capitalized
}
