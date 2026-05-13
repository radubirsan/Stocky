import Foundation

protocol HTTPSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {}

final class URLSessionHTTPClient: HTTPClient {
    private let session: HTTPSession
    private let config: APIConfig

    init(session: HTTPSession = URLSession.shared, config: APIConfig) {
        self.session = session
        self.config = config
    }

    func get(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try makeRequest(for: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            return try validate(data: data, response: response)
        } catch let error as DomainError {
            throw error
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError {
            throw Self.mapURLError(error)
        } catch {
            throw DomainError.unknown(error.localizedDescription)
        }
    }

    private func makeRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        let target = config.baseURL.appending(path: endpoint.path)
        var components = URLComponents(url: target, resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw DomainError.unknown("Could not build URL for \(endpoint.path).")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.addValue(config.host, forHTTPHeaderField: "x-rapidapi-host")
        request.addValue(config.apiKey, forHTTPHeaderField: "x-rapidapi-key")
        return request
    }

    private func validate(data: Data, response: URLResponse) throws -> Data {
        guard let http = response as? HTTPURLResponse else {
            throw DomainError.unknown("Non-HTTP response.")
        }
        switch http.statusCode {
        case 200...299:
            return data
        case 401, 403:
            throw DomainError.unauthorized
        case 404:
            throw DomainError.notFound
        case 400...599:
            let body = String(data: data, encoding: .utf8)
            throw DomainError.server(statusCode: http.statusCode, message: body)
        default:
            throw DomainError.server(statusCode: http.statusCode, message: nil)
        }
    }

    private static func mapURLError(_ error: URLError) -> DomainError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut,
             .dataNotAllowed, .internationalRoamingOff:
            return .networkUnavailable
        case .userAuthenticationRequired:
            return .unauthorized
        case .fileDoesNotExist, .resourceUnavailable:
            return .notFound
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
