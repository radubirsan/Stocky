import Foundation
@testable import Stocky

final class MockFetchStockListUseCase: FetchStockListUseCase, @unchecked Sendable {
    var result: Result<[Stock], Error> = .success([])
    private(set) var callCount = 0

    func execute() async throws -> [Stock] {
        callCount += 1
        return try result.get()
    }
}
