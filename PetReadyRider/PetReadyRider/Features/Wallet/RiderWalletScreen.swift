import SwiftUI
import PetReadyShared

struct RiderWalletScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    balanceCard
                    historyCard
                }
                .padding()
            }
            .background(DesignSystem.Colors.appBackground)
            .navigationTitle("Wallet")
        }
    }

    private var balanceCard: some View {
        riderCuteCard("Balance", gradient: [Color(hex: "E8FFE8"), Color(hex: "F0FFF0")]) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💰").font(.system(size: 40))
                    Text("Payout balance").font(.caption).foregroundStyle(.secondary)
                    Text("฿3,280")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [Color(hex: "98D8AA"), Color(hex: "A0D8F1")], startPoint: .leading, endPoint: .trailing)
                        )
                }
                Spacer()
                Button {} label: {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill").font(.title2)
                        Text("Withdraw").font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Color(hex: "98D8AA"), Color(hex: "A0D8F1")], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: Color(hex: "98D8AA").opacity(0.3), radius: 8, y: 4)
                }
            }
        }
    }

    private var historyCard: some View {
        riderCuteCard("History", gradient: [Color(hex: "E8F4FF"), Color(hex: "F0F8FF")]) {
            ForEach(0..<4, id: \.self) { idx in
                HStack(spacing: 14) {
                    Text("💵")
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white).shadow(color: .black.opacity(0.05), radius: 4, y: 2))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Job #\(idx + 210)").font(.body.weight(.semibold))
                        Text("Today").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("+฿320")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color(hex: "98D8AA"))
                }
                .padding(.vertical, 6)
                if idx < 3 {
                    Divider().padding(.leading, 54)
                }
            }
        }
    }
}
