import Foundation
@testable import Stocky

final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    var result: Result<Data, Error> = .success(Data())
    private(set) var receivedEndpoints: [APIEndpoint] = []

    var callCount: Int { receivedEndpoints.count }
    var lastEndpoint: APIEndpoint? { receivedEndpoints.last }

    func get(_ endpoint: APIEndpoint) async throws -> Data {
        receivedEndpoints.append(endpoint)
        return try result.get()
    }
}
