import SwiftUI
import PetReadyShared

struct AdminAnalyticsScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    cuteCard("💚 System Health", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
                        cuteRow(icon: "💯", title: "Uptime", subtitle: "99.9% - Amazing!", badge: "Excellent", badgeColor: Color(hex: "98D8AA"))
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "⏱️", title: "Response time", subtitle: "Average 7 minutes")
                        Divider().padding(.leading, 50)
                        cuteRow(icon: "📈", title: "Happy users", subtitle: "+18% more pets helped", badge: "+18%", badgeColor: Color(hex: "A0D8F1"))
                    }
                    cuteCard("🗺️ Regional Activity", gradient: [Color(hex: "FFE5F1"), Color(hex: "FFF0F7")]) {
                        VStack(spacing: 16) {
                            regionBubble("🏙️ Bangkok", percentage: 45, color: Color(hex: "FFB5D8"))
                            regionBubble("🏔️ Chiang Mai", percentage: 22, color: Color(hex: "A0D8F1"))
                            regionBubble("🏖️ Phuket", percentage: 15, color: Color(hex: "FFE5A0"))
                        }
                    }
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("📊 Analytics")
        }
    }

    private func regionBubble(_ name: String, percentage: Int, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.2)).frame(width: 60, height: 60)
                VStack(spacing: 2) {
                    Text("\(percentage)").font(.title3.bold()).foregroundStyle(color)
                    Text("%").font(.caption2.bold()).foregroundStyle(color.opacity(0.7))
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.body.weight(.semibold))
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.2)).frame(height: 8)
                        RoundedRectangle(cornerRadius: 10).fill(color).frame(width: geo.size.width * CGFloat(percentage) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
