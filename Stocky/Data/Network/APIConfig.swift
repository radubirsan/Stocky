import Foundation

struct APIConfig: Sendable {
    let baseURL: URL
    let host: String
    let apiKey: String
    let region: String

    static let production = APIConfig(
        baseURL: URL(string: "https://yahoo-finance-real-time1.p.rapidapi.com")!,
        host: "yahoo-finance-real-time1.p.rapidapi.com",
        apiKey: "ae94d2251cmsh5e41d39c78a1404p1c43e9jsnd74f7012cedf", // hide in  Secrets.xcconfig and don't commit to git ( left it so reviewer can test whiteout using his own key )
        region: "US"
    )
}
