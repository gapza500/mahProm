import SwiftUI
import PetReadyShared

struct OwnerChatView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("Waiting Queue", gradient: [Color(hex: "FFE5A0"), Color(hex: "FFF3D4")]) {
                        cuteInfoRow(icon: "⏱️", title: "Dr. Siri", subtitle: "ETA 5 min", badge: "Waiting", badgeColor: Color(hex: "FFE5A0"))
                    }

                    cuteCard("Conversations", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
                        ForEach(0..<2, id: \.self) { _ in
                            cuteInfoRow(icon: "💬", title: "Vet chat placeholder", subtitle: "Tap to continue", showChevron: true)
                            Divider().padding(.leading, 50)
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Chat")
        }
    }
}
