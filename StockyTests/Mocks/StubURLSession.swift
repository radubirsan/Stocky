import Foundation
@testable import Stocky

final class StubURLSession: HTTPSession, @unchecked Sendable {
    var result: Result<(Data, URLResponse), Error> = .success((Data(), HTTPURLResponse()))
    private(set) var capturedRequests: [URLRequest] = []

    var lastRequest: URLRequest? { capturedRequests.last }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequests.append(request)
        return try result.get()
    }
}
