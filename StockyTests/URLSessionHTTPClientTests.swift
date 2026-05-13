import XCTest
@testable import Stocky

final class URLSessionHTTPClientTests: XCTestCase {

    private var session: StubURLSession!
    private var sut: URLSessionHTTPClient!

    override func setUp() async throws {
        try await super.setUp()
        session = StubURLSession()
        sut = URLSessionHTTPClient(session: session, config: Self.config)
    }

    override func tearDown() async throws {
        sut = nil
        session = nil
        try await super.tearDown()
    }

    func test_get_buildsURLFromBaseAndEndpoint() async throws {
        session.stub(statusCode: 200)

        _ = try await sut.get(.quotes(symbols: ["AAPL", "MSFT"], region: "US"))

        let request = try XCTUnwrap(session.lastRequest)
        let components = try XCTUnwrap(
            URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)
        )
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(components.host, "test.example.com")
        XCTAssertEqual(components.path, "/market/get-quotes")
        XCTAssertEqual(
            Set(components.queryItems ?? []),
            Set([
                URLQueryItem(name: "region", value: "US"),
                URLQueryItem(name: "symbols", value: "AAPL,MSFT")
            ])
        )
    }

    func test_get_attachesRapidAPIAuthHeaders() async throws {
        session.stub(statusCode: 200)

        _ = try await sut.get(.summary(symbol: "AAPL", region: "US"))

        let request = try XCTUnwrap(session.lastRequest)
        XCTAssertEqual(request.value(forHTTPHeaderField: "x-rapidapi-host"), Self.config.host)
        XCTAssertEqual(request.value(forHTTPHeaderField: "x-rapidapi-key"), Self.config.apiKey)
    }

    func test_get_returnsData_on2xx() async throws {
        let body = Data("hello".utf8)
        session.stub(statusCode: 200, body: body)

        let data = try await sut.get(.summary(symbol: "AAPL", region: "US"))

        XCTAssertEqual(data, body)
    }

    func test_get_throwsUnauthorized_on401() async {
        session.stub(statusCode: 401)
        await assertThrows(.unauthorized) {
            _ = try await self.sut.get(.summary(symbol: "AAPL", region: "US"))
        }
    }

    func test_get_throwsNotFound_on404() async {
        session.stub(statusCode: 404)
        await assertThrows(.notFound) {
            _ = try await self.sut.get(.summary(symbol: "AAPL", region: "US"))
        }
    }

    func test_get_throwsServerError_on5xx_withBody() async throws {
        session.stub(statusCode: 503, body: Data("Service is overloaded".utf8))

        do {
            _ = try await sut.get(.summary(symbol: "AAPL", region: "US"))
            XCTFail("Expected .server")
        } catch DomainError.server(let statusCode, let message) {
            XCTAssertEqual(statusCode, 503)
            XCTAssertEqual(message, "Service is overloaded")
        }
    }

    func test_get_mapsURLError_toNetworkUnavailable() async {
        session.result = .failure(URLError(.notConnectedToInternet))
        await assertThrows(.networkUnavailable) {
            _ = try await self.sut.get(.summary(symbol: "AAPL", region: "US"))
        }
    }

    func test_get_translatesURLErrorCancelled_intoCancellationError() async {
        session.result = .failure(URLError(.cancelled))

        do {
            _ = try await sut.get(.summary(symbol: "AAPL", region: "US"))
            XCTFail("Expected CancellationError")
        } catch is CancellationError {
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }
}

private extension URLSessionHTTPClientTests {

    static let config = APIConfig(
        baseURL: URL(string: "https://test.example.com")!,
        host: "test.example.com",
        apiKey: "test-api-key",
        region: "US"
    )

    func assertThrows(
        _ expected: DomainError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected to throw \(expected)", file: file, line: line)
        } catch let domain as DomainError {
            XCTAssertEqual(domain, expected, file: file, line: line)
        } catch {
            XCTFail("Expected DomainError, got \(error)", file: file, line: line)
        }
    }
}

private extension StubURLSession {
    func stub(statusCode: Int, body: Data = Data()) {
        let response = HTTPURLResponse(
            url: URL(string: "https://test.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        result = .success((body, response))
    }
}
