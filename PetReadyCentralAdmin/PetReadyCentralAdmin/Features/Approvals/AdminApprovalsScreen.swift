import SwiftUI

struct AdminApprovalsScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("🩺 Vet Applications", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        ForEach(0..<3, id: \.self) { idx in
                            if idx > 0 { Divider().padding(.leading, 50) }
                            cuteRow(
                                icon: "👨‍⚕️",
                                title: "Dr. Applicants #\(idx + 41)",
                                subtitle: "License verification in progress",
                                showChevron: true
                            )
                        }
                    }
                    cuteCard("🚴 Rider Applications", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<5, id: \.self) { idx in
                            if idx > 0 { Divider().padding(.leading, 50) }
                            cuteRow(
                                icon: "🚴",
                                title: "Rider #\(idx + 120)",
                                subtitle: "Documents ready for review",
                                showChevron: true
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("✅ Approvals")
        }
    }
}
