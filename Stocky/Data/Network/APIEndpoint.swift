import Foundation

struct APIEndpoint: Sendable, Hashable {
    let path: String
    let queryItems: [URLQueryItem]

    init(path: String, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }
}

extension APIEndpoint {
    static func quotes(symbols: [String], region: String) -> APIEndpoint {
        APIEndpoint(
            path: "/market/get-quotes",
            queryItems: [
                URLQueryItem(name: "region", value: region),
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))
            ]
        )
    }

    static func summary(symbol: String, region: String) -> APIEndpoint {
        APIEndpoint(
            path: "/stock/get-summary",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "region", value: region)
            ]
        )
    }
}
