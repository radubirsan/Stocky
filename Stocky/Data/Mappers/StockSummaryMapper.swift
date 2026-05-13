import Foundation

enum StockSummaryMapper {
    private static let fractionToPercent: Double = 100

    static func map(_ dto: StockSummaryDTO, fallbackSymbol: String) throws -> StockSummary {
        let price = dto.price
        let detail = dto.summaryDetail
        let profile = dto.summaryProfile
        let quote = dto.quoteType

        let symbol = price?.symbol ?? quote?.symbol ?? fallbackSymbol

        guard let regularMarketPrice = price?.regularMarketPrice else {
            throw DomainError.decoding
        }

        let name = price?.longName
            ?? quote?.longName
            ?? price?.shortName
            ?? quote?.shortName
            ?? symbol

        return StockSummary(
            symbol: symbol,
            name: name,
            price: regularMarketPrice,
            change: price?.regularMarketChange,
            changePercent: price?.regularMarketChangePercent.map { $0 * fractionToPercent },
            previousClose: price?.regularMarketPreviousClose,
            open: price?.regularMarketOpen,
            dayHigh: price?.regularMarketDayHigh,
            dayLow: price?.regularMarketDayLow,
            volume: price?.regularMarketVolume,
            marketCap: price?.marketCap,
            fiftyTwoWeekHigh: detail?.fiftyTwoWeekHigh,
            fiftyTwoWeekLow: detail?.fiftyTwoWeekLow,
            trailingPE: detail?.trailingPE,
            dividendYield: detail?.dividendYield.map { $0 * fractionToPercent },
            currency: price?.currency ?? "USD",
            exchangeName: price?.exchangeName,
            industry: profile?.industry,
            sector: profile?.sector,
            website: profile?.website,
            businessSummary: profile?.longBusinessSummary
        )
    }
}
