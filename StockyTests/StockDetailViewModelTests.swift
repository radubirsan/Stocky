import XCTest
@testable import Stocky

final class StockDetailViewModelTests: XCTestCase {

    private var mockUseCase: MockFetchStockDetailUseCase!
    private var sut: StockDetailViewModel!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockFetchStockDetailUseCase()
        sut = StockDetailViewModel(
            symbol: "AAPL",
            useCase: mockUseCase
        )
    }

    @MainActor
    override func tearDown() async throws {
        sut = nil
        mockUseCase = nil
        try await super.tearDown()
    }

    @MainActor
    func test_init_capturesSymbolAndStartsIdle() {
        XCTAssertEqual(sut.symbol, "AAPL")
        XCTAssertEqual(sut.state, .idle)
    }

    @MainActor
    func test_load_setsLoaded_andForwardsSymbol_onSuccess() async {
        mockUseCase.result = .success(StockSummary.aapl)

        await sut.load()

        XCTAssertEqual(sut.state, .loaded(StockSummary.aapl))
        XCTAssertEqual(mockUseCase.receivedSymbols, ["AAPL"])
    }

    @MainActor
    func test_load_setsFailed_onError() async {
        mockUseCase.result = .failure(DomainError.notFound)

        await sut.load()

        XCTAssertEqual(sut.state, .failed(DomainError.notFound.localizedDescription))
    }

    @MainActor
    func test_refresh_preservesLoadedState_onFailure() async {
        mockUseCase.result = .success(StockSummary.aapl)
        await sut.load()

        mockUseCase.result = .failure(DomainError.networkUnavailable)
        await sut.refresh()

        XCTAssertEqual(sut.state, .loaded(StockSummary.aapl))
    }

    @MainActor
    func test_load_revertsToIdle_whenCancelled() async {
        mockUseCase.result = .failure(CancellationError())

        await sut.load()

        XCTAssertEqual(sut.state, .idle)
    }

    @MainActor
    func test_runAutoRefresh_callsRefreshRepeatedly_untilCancelled() async throws {
        mockUseCase.result = .success(StockSummary.aapl)

        let task = Task { await sut.runAutoRefresh(every: .milliseconds(5)) }
        try await Task.sleep(for: .milliseconds(60))

        XCTAssertGreaterThanOrEqual(mockUseCase.callCount, 3)
        task.cancel()
        await task.value
    }
}
