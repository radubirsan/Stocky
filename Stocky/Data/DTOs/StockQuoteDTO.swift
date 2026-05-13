import Foundation

struct StockQuotesResponseDTO: Decodable, Sendable {
    let quoteResponse: Body

    struct Body: Decodable, Sendable {
        let result: [StockQuoteDTO]?
    }
}

struct StockQuoteDTO: Decodable, Sendable {
    let symbol: String
    let shortName: String?
    let longName: String?
    let regularMarketPrice: Double?
    let regularMarketChange: Double?
    let regularMarketChangePercent: Double?
    let currency: String?
}
