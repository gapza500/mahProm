import Foundation
import Combine

@MainActor
final class WalletStore: ObservableObject {
    static let shared = WalletStore()

    @Published private(set) var balance: Double = 0
    @Published private(set) var transactions: [WalletTransaction] = []

    private init() {}

    func recordCompletion(amount: Double) {
        balance += amount
        transactions.insert(
            WalletTransaction(id: UUID(), amount: amount, date: Date(), description: "SOS completion payout"),
            at: 0
        )
    }

    var completedJobsCount: Int {
        transactions.count
    }
}

struct WalletTransaction: Identifiable {
    let id: UUID
    let amount: Double
    let date: Date
    let description: String
}
