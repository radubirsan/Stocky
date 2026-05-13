import Foundation

struct StockSummaryDTO: Decodable, Sendable {
    let quoteType: QuoteType?
    let price: Price?
    let summaryDetail: SummaryDetail?
    let summaryProfile: SummaryProfile?

    struct QuoteType: Decodable, Sendable {
        let symbol: String?
        let shortName: String?
        let longName: String?
    }

    struct Price: Decodable, Sendable {
        let symbol: String?
        let shortName: String?
        let longName: String?
        let currency: String?
        let exchangeName: String?
        let regularMarketPrice: Double?
        let regularMarketChange: Double?
        let regularMarketChangePercent: Double?
        let regularMarketPreviousClose: Double?
        let regularMarketOpen: Double?
        let regularMarketDayHigh: Double?
        let regularMarketDayLow: Double?
        let regularMarketVolume: Double?
        let marketCap: Double?
    }

    struct SummaryDetail: Decodable, Sendable {
        let fiftyTwoWeekHigh: Double?
        let fiftyTwoWeekLow: Double?
        let trailingPE: Double?
        let dividendYield: Double?
    }

    struct SummaryProfile: Decodable, Sendable {
        let industry: String?
        let sector: String?
        let website: String?
        let longBusinessSummary: String?
    }
}
