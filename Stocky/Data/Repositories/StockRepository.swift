import Foundation

final class StockRepository: StockRepositoryProtocol {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private let region: String

    init(httpClient: HTTPClient, region: String) {
        self.httpClient = httpClient
        self.decoder = JSONDecoder()
        self.region = region
    }

    func fetchStocks(symbols: [String]) async throws -> [Stock] {
        let data = try await httpClient.get(.quotes(symbols: symbols, region: region))
        let dto = try decode(StockQuotesResponseDTO.self, from: data)
        return (dto.quoteResponse.result ?? []).compactMap(StockMapper.map)
    }

    func fetchSummary(symbol: String) async throws -> StockSummary {
        let data = try await httpClient.get(.summary(symbol: symbol, region: region))
        let dto = try decode(StockSummaryDTO.self, from: data)
        return try StockSummaryMapper.map(dto, fallbackSymbol: symbol)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch is DecodingError {
            throw DomainError.decoding
        }
    }
}
