import XCTest
@testable import Stocky

final class StockMapperTests: XCTestCase {

    func test_map_returnsNil_whenPriceIsMissing() {
        let dto = StockQuoteDTO(
            symbol: "AAPL",
            shortName: "Apple Inc.",
            longName: nil,
            regularMarketPrice: nil,
            regularMarketChange: nil,
            regularMarketChangePercent: nil,
            currency: nil
        )

        XCTAssertNil(StockMapper.map(dto))
    }

    func test_map_returnsStockWithAllFields_whenPriceIsPresent() {
        let dto = StockQuoteDTO(
            symbol: "AAPL",
            shortName: "Apple Inc.",
            longName: "Apple Inc. (Common Stock)",
            regularMarketPrice: 293.81,
            regularMarketChange: 1.13,
            regularMarketChangePercent: 0.39,
            currency: "USD"
        )

        let stock = StockMapper.map(dto)

        XCTAssertEqual(stock?.symbol, "AAPL")
        XCTAssertEqual(stock?.name, "Apple Inc.")
        XCTAssertEqual(stock?.price, 293.81)
        XCTAssertEqual(stock?.change, 1.13)
        XCTAssertEqual(stock?.changePercent, 0.39)
        XCTAssertEqual(stock?.currency, "USD")
    }

    func test_map_fallsBackToSymbol_whenBothNamesMissing() {
        let dto = StockQuoteDTO(
            symbol: "AAPL",
            shortName: nil,
            longName: nil,
            regularMarketPrice: 1,
            regularMarketChange: nil,
            regularMarketChangePercent: nil,
            currency: nil
        )

        XCTAssertEqual(StockMapper.map(dto)?.name, "AAPL")
    }

    func test_map_defaultsMissingFieldsToZeroAndUSD() {
        let dto = StockQuoteDTO(
            symbol: "AAPL",
            shortName: "Apple Inc.",
            longName: nil,
            regularMarketPrice: 100,
            regularMarketChange: nil,
            regularMarketChangePercent: nil,
            currency: nil
        )

        let stock = StockMapper.map(dto)

        XCTAssertEqual(stock?.change, 0)
        XCTAssertEqual(stock?.changePercent, 0)
        XCTAssertEqual(stock?.currency, "USD")
    }
}
