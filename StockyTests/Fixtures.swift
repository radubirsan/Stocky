import Foundation
@testable import Stocky

extension Stock {
    static let aapl = Stock(
        symbol: "AAPL",
        name: "Apple Inc.",
        price: 293.81,
        change: 1.13,
        changePercent: 0.39,
        currency: "USD"
    )

    static let msft = Stock(
        symbol: "MSFT",
        name: "Microsoft Corporation",
        price: 482.50,
        change: -2.10,
        changePercent: -0.43,
        currency: "USD"
    )

    static let goog = Stock(
        symbol: "GOOG",
        name: "Alphabet Inc.",
        price: 178.20,
        change: 0.85,
        changePercent: 0.48,
        currency: "USD"
    )
}

extension StockSummary {
    static let aapl = StockSummary(
        symbol: "AAPL",
        name: "Apple Inc.",
        price: 293.81,
        change: 1.13,
        changePercent: 0.39,
        previousClose: 292.68,
        open: 292.75,
        dayHigh: 294.90,
        dayLow: 292.61,
        volume: 19_613_465,
        marketCap: 4_314_557_841_408,
        fiftyTwoWeekHigh: 294.90,
        fiftyTwoWeekLow: 193.46,
        trailingPE: 35.60,
        dividendYield: 0.37,
        currency: "USD",
        exchangeName: "NasdaqGS",
        industry: "Consumer Electronics",
        sector: "Technology",
        website: "https://www.apple.com",
        businessSummary: "Apple Inc. designs and sells consumer electronics."
    )
}
