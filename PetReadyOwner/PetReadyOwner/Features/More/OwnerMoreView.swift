import SwiftUI

struct OwnerMoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Care") {
                    NavigationLink("Clinics") { OwnerClinicsView() }
                    NavigationLink("Pet health info") { OwnerInfoView() }
                }
                Section("Account") {
                    NavigationLink("Settings") { OwnerSettingsView() }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
        }
    }
}

#Preview {
    OwnerMoreView()
}
