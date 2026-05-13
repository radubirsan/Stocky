import Foundation

/// `apiKey` is embedded for the interview only; in production it would
/// come from a build-time `.xcconfig` excluded from source control.
struct APIConfig: Sendable {
    let baseURL: URL
    let host: String
    let apiKey: String
    let region: String

    static let production = APIConfig(
        baseURL: URL(string: "https://yahoo-finance-real-time1.p.rapidapi.com")!,
        host: "yahoo-finance-real-time1.p.rapidapi.com",
        apiKey: "255cabfa77mshd679c791e61773bp12dca2jsnaa9531e09ee9", //Secrets.xcconfig for production code this will be loaded from a Secrets.xcconfig that is added to the .gitignore
        region: "US"
    )
}
