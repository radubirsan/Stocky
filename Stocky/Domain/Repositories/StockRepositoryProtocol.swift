import Foundation

protocol StockRepositoryProtocol: Sendable {
    func fetchStocks(symbols: [String]) async throws -> [Stock]
    func fetchSummary(symbol: String) async throws -> StockSummary
}
