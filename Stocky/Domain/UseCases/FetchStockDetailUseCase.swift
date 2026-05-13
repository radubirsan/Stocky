import Foundation

protocol FetchStockDetailUseCase: Sendable {
    func execute(symbol: String) async throws -> StockSummary
}

struct DefaultFetchStockDetailUseCase: FetchStockDetailUseCase {
    private let repository: StockRepositoryProtocol

    init(repository: StockRepositoryProtocol) {
        self.repository = repository
    }

    func execute(symbol: String) async throws -> StockSummary {
        try await repository.fetchSummary(symbol: symbol)
    }
}
