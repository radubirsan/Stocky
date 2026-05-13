import XCTest
@testable import Stocky

final class StockSummaryMapperTests: XCTestCase {

    func test_map_throwsDecoding_whenPriceMissing() {
        let dto = StockSummaryDTO(
            quoteType: nil,
            price: nil,
            summaryDetail: nil,
            summaryProfile: nil
        )

        XCTAssertThrowsError(try StockSummaryMapper.map(dto, fallbackSymbol: "X")) { error in
            XCTAssertEqual(error as? DomainError, .decoding)
        }
    }

    func test_map_forwardsAllPriceFields() throws {
        let dto = StockSummaryDTO(
            quoteType: nil,
            price: .init(
                symbol: "AAPL",
                shortName: nil,
                longName: nil,
                currency: "USD",
                exchangeName: "NasdaqGS",
                regularMarketPrice: 293.81,
                regularMarketChange: 1.13,
                regularMarketChangePercent: nil,
                regularMarketPreviousClose: 292.68,
                regularMarketOpen: 292.75,
                regularMarketDayHigh: 294.90,
                regularMarketDayLow: 292.61,
                regularMarketVolume: 19_613_465,
                marketCap: 4_314_557_841_408
            ),
            summaryDetail: nil,
            summaryProfile: nil
        )

        let summary = try StockSummaryMapper.map(dto, fallbackSymbol: "X")
        XCTAssertEqual(summary.symbol, "AAPL")
        XCTAssertEqual(summary.price, 293.81)
        XCTAssertEqual(summary.change, 1.13)
        XCTAssertEqual(summary.previousClose, 292.68)
        XCTAssertEqual(summary.currency, "USD")
        XCTAssertEqual(summary.exchangeName, "NasdaqGS")
    }

    func test_map_normalisesChangePercent_fromFractionToPercent() throws {
        let dto = StockSummaryDTO(
            quoteType: nil,
            price: .stub(regularMarketPrice: 1, regularMarketChangePercent: 0.00386),
            summaryDetail: nil,
            summaryProfile: nil
        )

        let summary = try StockSummaryMapper.map(dto, fallbackSymbol: "X")
        XCTAssertEqual(summary.changePercent ?? 0, 0.386, accuracy: 0.0001)
    }

    func test_map_defaultsCurrencyToUSD_whenMissing() throws {
        let dto = StockSummaryDTO(
            quoteType: nil,
            price: .stub(currency: nil, regularMarketPrice: 1),
            summaryDetail: nil,
            summaryProfile: nil
        )

        let summary = try StockSummaryMapper.map(dto, fallbackSymbol: "X")
        XCTAssertEqual(summary.currency, "USD")
    }

    func test_map_fallsBackToCallerSymbol_andSymbolAsName_whenDTOIsBare() throws {
        let dto = StockSummaryDTO(
            quoteType: nil,
            price: .stub(symbol: nil, regularMarketPrice: 1),
            summaryDetail: nil,
            summaryProfile: nil
        )

        let summary = try StockSummaryMapper.map(dto, fallbackSymbol: "AAPL")
        XCTAssertEqual(summary.symbol, "AAPL")
        XCTAssertEqual(summary.name, "AAPL")
    }
}

private extension StockSummaryDTO.Price {
    static func stub(
        symbol: String? = "AAPL",
        currency: String? = nil,
        regularMarketPrice: Double? = nil,
        regularMarketChangePercent: Double? = nil
    ) -> Self {
        .init(
            symbol: symbol,
            shortName: nil,
            longName: nil,
            currency: currency,
            exchangeName: nil,
            regularMarketPrice: regularMarketPrice,
            regularMarketChange: nil,
            regularMarketChangePercent: regularMarketChangePercent,
            regularMarketPreviousClose: nil,
            regularMarketOpen: nil,
            regularMarketDayHigh: nil,
            regularMarketDayLow: nil,
            regularMarketVolume: nil,
            marketCap: nil
        )
    }
}
