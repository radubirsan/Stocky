import XCTest
@testable import Stocky

final class StockSummaryTests: XCTestCase {

    func test_isPositive_treatsNilChangeAsPositive() {
        let summary = StockSummary(
            symbol: "AAPL",
            name: "Apple Inc.",
            price: 100,
            change: nil,
            changePercent: nil,
            previousClose: nil,
            open: nil,
            dayHigh: nil,
            dayLow: nil,
            volume: nil,
            marketCap: nil,
            fiftyTwoWeekHigh: nil,
            fiftyTwoWeekLow: nil,
            trailingPE: nil,
            dividendYield: nil,
            currency: "USD",
            exchangeName: nil,
            industry: nil,
            sector: nil,
            website: nil,
            businessSummary: nil
        )
        XCTAssertTrue(summary.isPositive)
    }
}
