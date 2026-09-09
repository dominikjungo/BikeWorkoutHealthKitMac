import Foundation

class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        
        // Configure decoder for ISO 8601 date format
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchWorkout(from urlString: String) async throws -> BikeWorkoutData {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let workoutData = try decoder.decode(BikeWorkoutData.self, from: data)
            return workoutData
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided. Please check the API endpoint."
        case .invalidResponse:
            return "Invalid response from server. Please check the API endpoint."
        case .httpError(let statusCode):
            return "HTTP Error \(statusCode). The server returned an error."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
