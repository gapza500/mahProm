import SwiftUI
import PetReadyShared

struct PatientsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { idx in
                        NavigationLink {
                            FeaturePlaceholderView(
                                title: "Patient Chart",
                                message: "Preview of how vet notes, attachments and realtime queue states will appear.",
                                icon: "📋",
                                highlights: ["Sync with shared pet profile", "Attach lab results + invoices"]
                            )
                            .navigationTitle("Bubbles \(idx + 1)")
                        } label: {
                            vetCuteCard("", gradient: [Color.white, Color.white]) {
                                HStack(spacing: 16) {
                                    Text("🐶")
                                        .font(.largeTitle)
                                        .frame(width: 50, height: 50)
                                        .background(Color(hex: "FFF0F5"), in: Circle())
                                    VStack(alignment: .leading) {
                                        Text("Bubbles")
                                            .font(.headline)
                                        Text("Owner Mint • 2w ago")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Patients")
        }
    }
}
