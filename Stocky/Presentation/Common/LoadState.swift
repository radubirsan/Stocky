import Foundation

enum LoadState<Value: Sendable>: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

extension LoadState: Equatable where Value: Equatable {}
