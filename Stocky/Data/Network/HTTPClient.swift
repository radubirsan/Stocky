import Foundation

protocol HTTPClient: Sendable {
    func get(_ endpoint: APIEndpoint) async throws -> Data
}
