import Foundation
import Observation

/// Composition root. `@Observable` so it can flow through `@Environment`;
/// `nonisolated init` so it can be created from `@State` defaults (only
/// stores `Sendable` references, so this is safe).
@MainActor
@Observable
final class DependencyContainer {
    @ObservationIgnored private let httpClient: HTTPClient
    @ObservationIgnored private let stockRepository: StockRepositoryProtocol
    @ObservationIgnored private let fetchStockListUseCase: FetchStockListUseCase
    @ObservationIgnored private let fetchStockDetailUseCase: FetchStockDetailUseCase

    nonisolated init(
        config: APIConfig = .production,
        watchlist: [String] = DependencyContainer.defaultWatchlist
    ) {
        let client = URLSessionHTTPClient(config: config)
        let repository = StockRepository(httpClient: client, region: config.region)
        self.httpClient = client
        self.stockRepository = repository
        self.fetchStockListUseCase = DefaultFetchStockListUseCase(
            repository: repository,
            watchlist: watchlist
        )
        self.fetchStockDetailUseCase = DefaultFetchStockDetailUseCase(
            repository: repository
        )
    }

    func makeStockListViewModel() -> StockListViewModel {
        StockListViewModel(useCase: fetchStockListUseCase)
    }

    func makeStockDetailViewModel(for stock: Stock) -> StockDetailViewModel {
        StockDetailViewModel(
            symbol: stock.symbol,
            useCase: fetchStockDetailUseCase
        )
    }

    static let defaultWatchlist = [
        "AAPL", "MSFT", "GOOG", "TSLA", "AMZN",
        "META", "NVDA", "NFLX", "AMD", "INTC"
    ]
}
