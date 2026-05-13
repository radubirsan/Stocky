import SwiftUI

struct ErrorStateView: View {
    let title: String
    let systemImage: String
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button("Retry", systemImage: "arrow.clockwise", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}
