import SwiftUI

struct StockRowView: View {
    let stock: Stock

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(stock.price, format: .currency(code: stock.currency))
                    .font(.headline)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: stock.price))
                    .animation(.snappy, value: stock.price)
                changeLabel
            }
        }
        .contentShape(.rect)
    }

    private var changeLabel: some View {
        let sign = stock.isPositive ? "+" : ""
        let text = "\(sign)\(stock.changePercent.formatted(.number.precision(.fractionLength(2))))%"
        return Text(text)
            .font(.subheadline)
            .monospacedDigit()
            .foregroundStyle(stock.isPositive ? Color.green : Color.red)
    }
}

#Preview {
    StockRowView(
        stock: Stock(
            symbol: "AAPL",
            name: "Apple Inc.",
            price: 191.31,
            change: -0.61,
            changePercent: -0.318,
            currency: "USD"
        )
    )
    .padding()
}
