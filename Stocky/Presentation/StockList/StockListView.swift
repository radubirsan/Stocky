import SwiftUI

@MainActor
struct StockListView: View {
    @State private var viewModel: StockListViewModel

    init(viewModel: StockListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Stocks")
            .searchable(text: $viewModel.searchQuery, prompt: "Search symbol or name")
            .task {
                if case .idle = viewModel.state {
                    await viewModel.load()
                }
                await viewModel.runAutoRefresh()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading stocks…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            list
        case .failed(let message):
            ErrorStateView(
                title: "Couldn't load stocks",
                systemImage: "wifi.exclamationmark",
                message: message
            ) {
                Task { await viewModel.load() }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.visibleStocks) { stock in
                NavigationLink(value: AppRoute.stockDetail(stock)) {
                    StockRowView(stock: stock)
                }
            }
        }
        .listStyle(.plain)
        .overlay { emptyOverlay }
    }

    @ViewBuilder
    private var emptyOverlay: some View {
        if case .loaded(let stocks) = viewModel.state {
            if stocks.isEmpty {
                ContentUnavailableView {
                    Label("No stocks", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("There's nothing to show right now.")
                } actions: {
                    Button("Retry", systemImage: "arrow.clockwise") {
                        Task { await viewModel.load() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if viewModel.visibleStocks.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}

