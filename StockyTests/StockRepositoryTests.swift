import XCTest
@testable import Stocky

final class StockRepositoryTests: XCTestCase {

    private var http: MockHTTPClient!
    private var sut: StockRepository!

    override func setUp() async throws {
        try await super.setUp()
        http = MockHTTPClient()
        sut = StockRepository(httpClient: http, region: "US")
    }

    override func tearDown() async throws {
        sut = nil
        http = nil
        try await super.tearDown()
    }

    func test_fetchStocks_hitsQuotesEndpoint_withSymbolsAndRegion() async throws {
        http.result = .success(Self.quotesPayload(rows: [Self.aaplQuoteJSON]))

        _ = try await sut.fetchStocks(symbols: ["AAPL", "MSFT"])

        let endpoint = try XCTUnwrap(http.lastEndpoint)
        XCTAssertEqual(endpoint.path, "/market/get-quotes")
        XCTAssertEqual(
            endpoint.queryItems,
            [
                URLQueryItem(name: "region", value: "US"),
                URLQueryItem(name: "symbols", value: "AAPL,MSFT")
            ]
        )
    }

    func test_fetchStocks_decodesAndMapsRows() async throws {
        http.result = .success(
            Self.quotesPayload(rows: [Self.aaplQuoteJSON, Self.msftQuoteJSON])
        )

        let stocks = try await sut.fetchStocks(symbols: ["AAPL", "MSFT"])

        XCTAssertEqual(stocks.map(\.symbol), ["AAPL", "MSFT"])
        XCTAssertEqual(stocks[0].name, "Apple Inc.")
        XCTAssertEqual(stocks[0].price, 293.81)
    }

    func test_fetchStocks_returnsEmpty_whenNoRows() async throws {
        http.result = .success(Self.quotesPayload(rows: []))

        let stocks = try await sut.fetchStocks(symbols: ["AAPL"])

        XCTAssertEqual(stocks, [])
    }

    func test_fetchStocks_translatesDecodingError_intoDomainDecoding() async {
        http.result = .success(Data("not json".utf8))

        await XCTAssertThrowsErrorAsync(
            try await sut.fetchStocks(symbols: ["AAPL"])
        ) { error in
            XCTAssertEqual(error as? DomainError, .decoding)
        }
    }

    func test_fetchStocks_propagatesDomainErrorFromHTTPClient() async {
        http.result = .failure(DomainError.networkUnavailable)

        await XCTAssertThrowsErrorAsync(
            try await sut.fetchStocks(symbols: ["AAPL"])
        ) { error in
            XCTAssertEqual(error as? DomainError, .networkUnavailable)
        }
    }

    func test_fetchSummary_decodesAndMapsResponse() async throws {
        http.result = .success(Self.summaryPayload)

        let summary = try await sut.fetchSummary(symbol: "AAPL")

        XCTAssertEqual(summary.symbol, "AAPL")
        XCTAssertEqual(summary.name, "Apple Inc.")
        XCTAssertEqual(summary.price, 293.81)
        XCTAssertEqual(summary.currency, "USD")
    }

    func test_fetchSummary_throwsDecoding_whenPayloadHasNoPrice() async {
        http.result = .success(Data("{}".utf8))

        await XCTAssertThrowsErrorAsync(
            try await sut.fetchSummary(symbol: "AAPL")
        ) { error in
            XCTAssertEqual(error as? DomainError, .decoding)
        }
    }
}

private extension StockRepositoryTests {

    static let aaplQuoteJSON = """
    {
        "symbol": "AAPL",
        "shortName": "Apple Inc.",
        "longName": "Apple Inc.",
        "regularMarketPrice": 293.81,
        "regularMarketChange": 1.13,
        "regularMarketChangePercent": 0.39,
        "currency": "USD"
    }
    """

    static let msftQuoteJSON = """
    {
        "symbol": "MSFT",
        "shortName": "Microsoft Corporation",
        "regularMarketPrice": 482.50,
        "regularMarketChange": -2.10,
        "regularMarketChangePercent": -0.43,
        "currency": "USD"
    }
    """

    static func quotesPayload(rows: [String]) -> Data {
        Data("""
        { "quoteResponse": { "result": [\(rows.joined(separator: ","))] } }
        """.utf8)
    }

    static let summaryPayload: Data = Data("""
    {
        "price": {
            "symbol": "AAPL",
            "shortName": "Apple Inc.",
            "longName": "Apple Inc.",
            "currency": "USD",
            "exchangeName": "NasdaqGS",
            "regularMarketPrice": 293.81,
            "regularMarketChange": 1.13,
            "regularMarketChangePercent": 0.00386,
            "regularMarketPreviousClose": 292.68,
            "regularMarketOpen": 292.75,
            "regularMarketDayHigh": 294.90,
            "regularMarketDayLow": 292.61,
            "regularMarketVolume": 19613465,
            "marketCap": 4314557841408
        },
        "summaryDetail": {
            "fiftyTwoWeekHigh": 294.90,
            "fiftyTwoWeekLow": 193.46,
            "trailingPE": 35.60,
            "dividendYield": 0.0037
        },
        "summaryProfile": {
            "industry": "Consumer Electronics",
            "sector": "Technology",
            "website": "https://www.apple.com",
            "longBusinessSummary": "Apple Inc. designs and sells consumer electronics."
        }
    }
    """.utf8)
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(
            "Expected expression to throw. \(message())",
            file: file,
            line: line
        )
    } catch {
        errorHandler(error)
    }
}
