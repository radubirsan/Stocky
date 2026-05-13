import Foundation
import Observation

@MainActor
@Observable
final class StockListViewModel {
    private(set) var state: LoadState<[Stock]> = .idle

    var searchQuery: String = "" {
        didSet {
            guard searchQuery != oldValue else { return }
            scheduleSearchDebounce()
        }
    }

    private(set) var debouncedSearchQuery: String = ""

    @ObservationIgnored private let useCase: FetchStockListUseCase
    @ObservationIgnored private let searchDebounce: Duration
    @ObservationIgnored private var loadGeneration = 0
    @ObservationIgnored private var debounceTask: Task<Void, Never>?

    init(useCase: FetchStockListUseCase, searchDebounce: Duration = .milliseconds(300)) {
        self.useCase = useCase
        self.searchDebounce = searchDebounce
    }

    var visibleStocks: [Stock] {
        guard case let .loaded(stocks) = state else { return [] }
        let query = debouncedSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return stocks }
        return stocks.filter {
            $0.symbol.localizedStandardContains(query)
                || $0.name.localizedStandardContains(query)
        }
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
            let stocks = try await useCase.execute()
            guard generation == loadGeneration else { return }
            state = .loaded(stocks)
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

    private func scheduleSearchDebounce() {
        debounceTask?.cancel()
        let interval = searchDebounce
        debounceTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: interval)
            } catch {
                return
            }
            guard let self else { return }
            self.debouncedSearchQuery = self.searchQuery
        }
    }
}
