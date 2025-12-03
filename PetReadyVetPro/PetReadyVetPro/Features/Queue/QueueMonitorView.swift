import SwiftUI

struct QueueMonitorView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    vetCuteCard("Waiting", gradient: [Color(hex: "FFE5A0").opacity(0.2), Color.white]) {
                        ForEach(0..<3, id: \.self) { idx in
                            vetCuteInfoRow(icon: "⏳", title: "Owner #\(idx + 312)", subtitle: "Waiting 3m • Auto-escalate in 12m")
                            if idx < 2 { Divider().padding(.leading, 50) }
                        }
                    }
                    vetCuteCard("Completed", gradient: [Color(hex: "98D8AA").opacity(0.2), Color.white]) {
                        ForEach(0..<2, id: \.self) { idx in
                            vetCuteInfoRow(icon: "✅", title: "Case #\(idx + 123)", subtitle: "Resolved successfully")
                        }
                    }
                }
                .padding()
            }
            .background(Color(hex: "FFF9FB"))
            .navigationTitle("Queue")
        }
    }
}
