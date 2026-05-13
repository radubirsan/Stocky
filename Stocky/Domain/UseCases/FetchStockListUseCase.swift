import Foundation

protocol FetchStockListUseCase: Sendable {
    func execute() async throws -> [Stock]
}

struct DefaultFetchStockListUseCase: FetchStockListUseCase {
    private let repository: StockRepositoryProtocol
    private let watchlist: [String]

    init(repository: StockRepositoryProtocol, watchlist: [String]) {
        self.repository = repository
        self.watchlist = watchlist
    }

    func execute() async throws -> [Stock] {
        try await repository.fetchStocks(symbols: watchlist)
    }
}
