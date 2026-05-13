import XCTest
@testable import Stocky

final class StockTests: XCTestCase {

    func test_isPositive_isTrue_whenChangeIsPositive() {
        let stock = Self.make(change: 1.13)
        XCTAssertTrue(stock.isPositive)
    }

    func test_isPositive_isFalse_whenChangeIsNegative() {
        let stock = Self.make(change: -2.10)
        XCTAssertFalse(stock.isPositive)
    }
}

private extension StockTests {
    static func make(change: Double) -> Stock {
        Stock(
            symbol: "AAPL",
            name: "Apple Inc.",
            price: 100,
            change: change,
            changePercent: 0,
            currency: "USD"
        )
    }
}
