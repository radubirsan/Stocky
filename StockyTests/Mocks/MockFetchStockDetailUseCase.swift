import Foundation
@testable import Stocky

final class MockFetchStockDetailUseCase: FetchStockDetailUseCase, @unchecked Sendable {
    var result: Result<StockSummary, Error> = .failure(DomainError.unknown("not configured"))
    private(set) var receivedSymbols: [String] = []
    var callCount: Int { receivedSymbols.count }

    func execute(symbol: String) async throws -> StockSummary {
        receivedSymbols.append(symbol)
        return try result.get()
    }
}
