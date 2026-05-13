import SwiftUI

@main
struct StockyApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
        }
    }
}

private struct RootView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var router: AppRouter

    @MainActor
    init() {
        _router = State(wrappedValue: AppRouter())
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            StockListView(viewModel: container.makeStockListViewModel())
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .environment(router)
    }

    @MainActor
    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .stockDetail(let stock):
            StockDetailView(viewModel: container.makeStockDetailViewModel(for: stock))
        }
    }
}
