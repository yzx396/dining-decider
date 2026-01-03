import Foundation
import CoreLocation
import DiningDeciderCore

// MARK: - Configuration

enum APIConfig {
    static var baseURL: String {
        guard let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
              !url.isEmpty,
              !url.contains("$(") else {
            return ""
        }
        return url
    }

    static var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String,
              !key.isEmpty,
              !key.contains("$(") else {
            return ""
        }
        return key
    }

    static var isConfigured: Bool {
        !baseURL.isEmpty && !apiKey.isEmpty
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError, Equatable {
    case notConfigured
    case invalidURL
    case unauthorized
    case networkError(String)
    case decodingError(String)
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API not configured. Check xcconfig setup."
        case .invalidURL:
            return "Invalid URL"
        case .unauthorized:
            return "Invalid API key"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        }
    }
}

// MARK: - Protocol

protocol RestaurantAPIProviding: Sendable {
    func fetchRestaurants(
        category: String,
        location: CLLocationCoordinate2D,
        radiusMiles: Double,
        priceLevels: [Int]?
    ) async throws -> [Restaurant]

    func fetchCategories() async throws -> [String]
}

// MARK: - Implementation

final class APIService: RestaurantAPIProviding, @unchecked Sendable {

    private let session: URLSession
    private let baseURL: String
    private let apiKey: String

    init(
        baseURL: String = APIConfig.baseURL,
        apiKey: String = APIConfig.apiKey,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }

    func fetchRestaurants(
        category: String,
        location: CLLocationCoordinate2D,
        radiusMiles: Double,
        priceLevels: [Int]?
    ) async throws -> [Restaurant] {
        guard !baseURL.isEmpty, !apiKey.isEmpty else {
            throw APIError.notConfigured
        }

        var components = URLComponents(string: "\(baseURL)/restaurants")
        components?.queryItems = [
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "lat", value: String(location.latitude)),
            URLQueryItem(name: "lng", value: String(location.longitude)),
            URLQueryItem(name: "radiusMiles", value: String(radiusMiles)),
            URLQueryItem(name: "shuffle", value: "true"),
            URLQueryItem(name: "limit", value: "3")
        ]

        if let levels = priceLevels, !levels.isEmpty {
            let levelsString = levels.map(String.init).joined(separator: ",")
            components?.queryItems?.append(
                URLQueryItem(name: "priceLevels", value: levelsString)
            )
        }

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let response: RestaurantsAPIResponse = try await request(url: url)
        return response.data
    }

    func fetchCategories() async throws -> [String] {
        guard !baseURL.isEmpty, !apiKey.isEmpty else {
            throw APIError.notConfigured
        }

        guard let url = URL(string: "\(baseURL)/categories") else {
            throw APIError.invalidURL
        }

        let response: CategoriesAPIResponse = try await request(url: url)
        return response.data
    }

    // MARK: - Private

    private func request<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(0, "Invalid response")
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, body)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - Response Types

private struct RestaurantsAPIResponse: Decodable {
    let success: Bool
    let data: [Restaurant]
}

private struct CategoriesAPIResponse: Decodable {
    let success: Bool
    let data: [String]
}
