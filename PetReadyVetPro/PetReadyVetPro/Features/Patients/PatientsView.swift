import SwiftUI

struct PatientsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in
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
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Patients")
        }
    }
}
