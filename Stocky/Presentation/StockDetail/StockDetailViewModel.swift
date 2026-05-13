import Foundation
import Observation

@MainActor
@Observable
final class StockDetailViewModel {
    let symbol: String
    private(set) var state: LoadState<StockSummary> = .idle

    @ObservationIgnored private let useCase: FetchStockDetailUseCase
    @ObservationIgnored private var loadGeneration = 0

    init(symbol: String, useCase: FetchStockDetailUseCase) {
        self.symbol = symbol
        self.useCase = useCase
    }

    func load() async {
        let generation = nextGeneration()
        state = .loading
        await fetch(generation: generation, preservingLoadedOnFailure: false)
    }

    func refresh() async {
        let generation = nextGeneration()
        await fetch(generation: generation, preservingLoadedOnFailure: true)
    }

    func runAutoRefresh(every interval: Duration = .seconds(8)) async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(for: interval)
            } catch {
                return
            }
            await refresh()
        }
    }

    private func nextGeneration() -> Int {
        loadGeneration += 1
        return loadGeneration
    }

    private func fetch(generation: Int, preservingLoadedOnFailure: Bool) async {
        do {
            let summary = try await useCase.execute(symbol: symbol)
            guard generation == loadGeneration else { return }
            state = .loaded(summary)
        } catch {
            guard generation == loadGeneration else { return }
            if error is CancellationError {
                if !preservingLoadedOnFailure { state = .idle }
                return
            }
            if preservingLoadedOnFailure, case .loaded = state { return }
            state = .failed(error.localizedDescription)
        }
    }
}
