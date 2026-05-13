import XCTest
@testable import Stocky

final class AppRouterTests: XCTestCase {

    private var sut: AppRouter!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        sut = AppRouter()
    }

    @MainActor
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    @MainActor
    func test_init_pathIsEmpty() {
        XCTAssertEqual(sut.path.count, 0)
    }

    @MainActor
    func test_navigate_pushesRouteOntoPath() {
        sut.navigate(to: .stockDetail(.aapl))
        XCTAssertEqual(sut.path.count, 1)
    }

    @MainActor
    func test_pop_removesLastEntry() {
        sut.navigate(to: .stockDetail(.aapl))
        sut.navigate(to: .stockDetail(.msft))

        sut.pop()

        XCTAssertEqual(sut.path.count, 1)
    }

    @MainActor
    func test_popToRoot_emptiesPath() {
        sut.navigate(to: .stockDetail(.aapl))
        sut.navigate(to: .stockDetail(.msft))

        sut.popToRoot()

        XCTAssertEqual(sut.path.count, 0)
    }
}
