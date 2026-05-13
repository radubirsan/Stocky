import SwiftUI

@MainActor
struct StockDetailView: View {
    @State private var viewModel: StockDetailViewModel

    init(viewModel: StockDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(viewModel.symbol)
            .navigationBarTitleDisplayMode(.inline)
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
            ProgressView("Loading \(viewModel.symbol)…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let summary):
            StockSummaryContent(summary: summary)
        case .failed(let message):
            ErrorStateView(
                title: "Couldn't load \(viewModel.symbol)",
                systemImage: "exclamationmark.triangle",
                message: message
            ) {
                Task { await viewModel.load() }
            }
        }
    }
}

private struct StockSummaryContent: View {
    let summary: StockSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StockSummaryHeader(summary: summary)
                StockSummaryPriceSection(summary: summary)
                StockSummaryStatsSection(summary: summary)
                if let about = summary.businessSummary, !about.isEmpty {
                    StockSummaryAboutSection(text: about)
                }
            }
            .padding()
        }
    }
}

private struct StockSummaryHeader: View {
    let summary: StockSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summary.name)
                .font(.title2)
                .bold()
            if let exchange = summary.exchangeName {
                Text(exchange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct StockSummaryPriceSection: View {
    let summary: StockSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(summary.price, format: .currency(code: summary.currency))
                .font(.system(.largeTitle, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: summary.price))
                .animation(.snappy, value: summary.price)

            if let change = summary.change, let percent = summary.changePercent {
                let sign = summary.isPositive ? "+" : ""
                let changeText = "\(sign)\(change.formatted(.number.precision(.fractionLength(2))))"
                let percentText = "\(sign)\(percent.formatted(.number.precision(.fractionLength(2))))%"

                HStack(spacing: 8) {
                    Image(systemName: summary.isPositive ? "arrow.up.right" : "arrow.down.right")
                    Text("\(changeText) (\(percentText))")
                        .monospacedDigit()
                }
                .font(.headline)
                .foregroundStyle(summary.isPositive ? Color.green : Color.red)
            }
        }
    }
}

private struct StockSummaryStatsSection: View {
    let summary: StockSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key statistics")
                .font(.headline)

            VStack(spacing: 0) {
                StatRow(label: "Open", value: summary.open.map(formatted))
                StatRow(label: "Previous close", value: summary.previousClose.map(formatted))
                StatRow(label: "Day high", value: summary.dayHigh.map(formatted))
                StatRow(label: "Day low", value: summary.dayLow.map(formatted))
                StatRow(label: "52-week high", value: summary.fiftyTwoWeekHigh.map(formatted))
                StatRow(label: "52-week low", value: summary.fiftyTwoWeekLow.map(formatted))
                StatRow(label: "Volume", value: summary.volume.map(formattedInteger))
                StatRow(label: "Market cap", value: summary.marketCap.map(compactFormatted))
                StatRow(label: "P/E (TTM)", value: summary.trailingPE.map(formatted))
                if let yield = summary.dividendYield {
                    StatRow(label: "Dividend yield", value: "\(yield.formatted(.number.precision(.fractionLength(2))))%")
                }
                StatRow(label: "Sector", value: summary.sector)
                StatRow(label: "Industry", value: summary.industry)
            }
            .background(Color.secondary.opacity(0.08), in: .rect(cornerRadius: 12))
        }
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }

    private func formattedInteger(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)).grouping(.automatic))
    }

    private func compactFormatted(_ value: Double) -> String {
        value.formatted(.number.notation(.compactName).precision(.fractionLength(0...2)))
    }
}

private struct StatRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value ?? "—")
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.leading, 12)
        }
    }
}

private struct StockSummaryAboutSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
