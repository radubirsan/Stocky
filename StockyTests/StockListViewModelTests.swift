import XCTest
@testable import Stocky

final class StockListViewModelTests: XCTestCase {

    private var mockUseCase: MockFetchStockListUseCase!
    private var sut: StockListViewModel!

    private static let testDebounce: Duration = .milliseconds(5)
    private static let debounceFlush: Duration = .milliseconds(40)

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        mockUseCase = MockFetchStockListUseCase()
        sut = StockListViewModel(useCase: mockUseCase, searchDebounce: Self.testDebounce)
    }

    @MainActor
    override func tearDown() async throws {
        sut = nil
        mockUseCase = nil
        try await super.tearDown()
    }

    @MainActor
    func test_init_setsIdleState() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertEqual(sut.searchQuery, "")
    }

    @MainActor
    func test_load_setsLoadedState_onSuccess() async {
        let stocks = [Stock.aapl, Stock.msft, Stock.goog]
        mockUseCase.result = .success(stocks)

        await sut.load()

        XCTAssertEqual(sut.state, .loaded(stocks))
    }

    @MainActor
    func test_load_setsFailedState_onError() async {
        mockUseCase.result = .failure(DomainError.networkUnavailable)

        await sut.load()

        XCTAssertEqual(sut.state, .failed(DomainError.networkUnavailable.localizedDescription))
    }

    @MainActor
    func test_load_setsLoadedWithEmptyArray_whenUseCaseReturnsEmpty() async {
        mockUseCase.result = .success([])

        await sut.load()

        XCTAssertEqual(sut.state, .loaded([]))
        XCTAssertTrue(sut.visibleStocks.isEmpty)
    }

    @MainActor
    func test_refresh_setsLoaded_onSuccess() async {
        mockUseCase.result = .success([Stock.aapl])

        await sut.refresh()

        XCTAssertEqual(sut.state, .loaded([Stock.aapl]))
    }

    @MainActor
    func test_refresh_preservesLoadedState_onFailure() async {
        mockUseCase.result = .success([Stock.aapl, Stock.msft])
        await sut.load()

        mockUseCase.result = .failure(DomainError.networkUnavailable)
        await sut.refresh()

        XCTAssertEqual(sut.state, .loaded([Stock.aapl, Stock.msft]))
    }

    @MainActor
    func test_load_revertsToIdle_whenCancelled() async {
        mockUseCase.result = .failure(CancellationError())

        await sut.load()

        XCTAssertEqual(sut.state, .idle)
    }

    @MainActor
    func test_refresh_preservesLoadedState_whenCancelled() async {
        mockUseCase.result = .success([Stock.aapl])
        await sut.load()

        mockUseCase.result = .failure(CancellationError())
        await sut.refresh()

        XCTAssertEqual(sut.state, .loaded([Stock.aapl]))
    }

    @MainActor
    func test_visibleStocks_filtersBySymbol_caseInsensitively() async throws {
        mockUseCase.result = .success([Stock.aapl, Stock.msft, Stock.goog])
        await sut.load()

        sut.searchQuery = "aapl"
        try await Task.sleep(for: Self.debounceFlush)

        XCTAssertEqual(sut.visibleStocks, [Stock.aapl])
    }

    @MainActor
    func test_visibleStocks_filtersByName_caseInsensitively() async throws {
        mockUseCase.result = .success([Stock.aapl, Stock.msft, Stock.goog])
        await sut.load()

        sut.searchQuery = "microsoft"
        try await Task.sleep(for: Self.debounceFlush)

        XCTAssertEqual(sut.visibleStocks, [Stock.msft])
    }

    @MainActor
    func test_searchQuery_updatesDebouncedQueryAfterInterval() async throws {
        sut.searchQuery = "apple"
        try await Task.sleep(for: Self.debounceFlush)

        XCTAssertEqual(sut.debouncedSearchQuery, "apple")
    }

    @MainActor
    func test_runAutoRefresh_callsRefreshRepeatedly_untilCancelled() async throws {
        mockUseCase.result = .success([Stock.aapl])

        let task = Task { await sut.runAutoRefresh(every: .milliseconds(5)) }
        try await Task.sleep(for: .milliseconds(60))

        XCTAssertGreaterThanOrEqual(mockUseCase.callCount, 3)
        task.cancel()
        await task.value
    }
}
