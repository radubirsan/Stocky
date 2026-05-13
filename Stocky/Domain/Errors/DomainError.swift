import Foundation

/// Single error currency. The data layer translates `URLError`,
/// `DecodingError`, and HTTP statuses into one of these so the
/// presentation layer only reads `localizedDescription`.
enum DomainError: LocalizedError, Sendable, Equatable {
    case networkUnavailable
    case unauthorized
    case notFound
    case server(statusCode: Int, message: String?)
    case decoding
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "You appear to be offline. Check your connection and try again."
        case .unauthorized:
            return "Your access to the data service is no longer valid."
        case .notFound:
            return "The requested information could not be found."
        case .server(let code, let message):
            if let message, !message.isEmpty {
                return message
            }
            return "The server returned an error (\(code))."
        case .decoding:
            return "Received an unexpected response from the server."
        case .unknown(let detail):
            return detail.isEmpty ? "Something went wrong." : detail
        }
    }
}
