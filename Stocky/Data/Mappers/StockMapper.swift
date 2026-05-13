import Foundation

enum StockMapper {
    static func map(_ dto: StockQuoteDTO) -> Stock? {
        guard let price = dto.regularMarketPrice else {
            return nil
        }
        return Stock(
            symbol: dto.symbol,
            name: dto.shortName ?? dto.longName ?? dto.symbol,
            price: price,
            change: dto.regularMarketChange ?? 0,
            changePercent: dto.regularMarketChangePercent ?? 0,
            currency: dto.currency ?? "USD"
        )
    }
}
