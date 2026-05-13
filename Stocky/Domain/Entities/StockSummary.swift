import Foundation

struct StockSummary: Sendable, Hashable {
    let symbol: String
    let name: String

    let price: Double
    let change: Double?
    let changePercent: Double?
    let previousClose: Double?
    let open: Double?
    let dayHigh: Double?
    let dayLow: Double?
    let volume: Double?
    let marketCap: Double?

    let fiftyTwoWeekHigh: Double?
    let fiftyTwoWeekLow: Double?
    let trailingPE: Double?
    let dividendYield: Double?

    let currency: String
    let exchangeName: String?
    let industry: String?
    let sector: String?
    let website: String?
    let businessSummary: String?

    var isPositive: Bool { (change ?? 0) >= 0 }
}
