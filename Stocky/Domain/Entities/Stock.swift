import Foundation

struct Stock: Sendable, Hashable, Identifiable {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let currency: String

    var id: String { symbol }
    var isPositive: Bool { change >= 0 }
}
