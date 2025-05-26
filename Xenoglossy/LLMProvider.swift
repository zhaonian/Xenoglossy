import Foundation

protocol LLMProvider {
    func transformText(_ text: String, tone: Tone) async throws -> String
}

enum LLMError: Error, LocalizedError {
    case apiKeyNotConfigured
    case invalidResponse
    case networkError
    case timeout
    case invalidAPIKey
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "API key is not configured. Please configure your API key in the menu bar."
        case .invalidResponse:
            return "Received an invalid response from the LLM."
        case .networkError:
            return "Network error occurred. Please check your internet connection."
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidAPIKey:
            return "Invalid API key. Please check your API key and try again."
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
} 
