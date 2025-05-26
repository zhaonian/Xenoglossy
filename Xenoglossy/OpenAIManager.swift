import Foundation
import SwiftUI
import Security
import OpenAI

class OpenAIManager: ObservableObject {
    static let shared = OpenAIManager()
    private let service = "io.zluan.xenoglossy"
    private let account = "openai_api_key"
    private var openAI: OpenAI?
    
    @Published var isConfigured: Bool = false
    
    private init() {
        checkApiKey()
    }
    
    func checkApiKey() {
        if let apiKey = getApiKey() {
            openAI = OpenAI(apiToken: apiKey)
            isConfigured = true
        } else {
            isConfigured = false
        }
    }
    
    func saveApiKey(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessGroup as String: "io.zluan.xenoglossy"
        ]
        
        // First try to delete any existing key
        SecItemDelete(query as CFDictionary)
        
        // Then add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            openAI = OpenAI(apiToken: key)
            isConfigured = true
        } else {
            print("Error saving API key: \(status)")
        }
    }
    
    func getApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecAttrAccessGroup as String: "io.zluan.xenoglossy"
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let key = String(data: data, encoding: .utf8) {
            return key
        }
        return nil
    }
    
    func removeApiKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessGroup as String: "io.zluan.xenoglossy"
        ]
        
        SecItemDelete(query as CFDictionary)
        openAI = nil
        isConfigured = false
    }
    
    func transformText(_ text: String, tone: Tone = .professional) async throws -> String {
        guard let openAI = openAI else {
            throw OpenAIError.apiKeyNotConfigured
        }
        
        let prompt = """
        \(tone.prompt)
        
        \(text)
        """
        
        do {
            guard let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
                throw OpenAIError.invalidResponse
            }
            
            let query = ChatQuery(
                messages: [userMessage],
                model: .gpt4_1_nano
            )
            
            let result = try await openAI.chats(query: query)
            guard let response = result.choices.first?.message.content else {
                throw OpenAIError.invalidResponse
            }
            
            return response
        } catch let error as OpenAIError {
            throw error
        } catch {
            // Check for specific API errors
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet:
                    throw OpenAIError.networkError
                case .timedOut:
                    throw OpenAIError.timeout
                default:
                    throw OpenAIError.networkError
                }
            }
            
            // Check for API key validation errors
            if let error = error as? OpenAIError {
                switch error {
                case .invalidAPIKey:
                    // Remove the invalid key
                    removeApiKey()
                    throw OpenAIError.invalidAPIKey
                default:
                    throw error
                }
            }
            
            throw OpenAIError.unknown(error.localizedDescription)
        }
    }
}

enum OpenAIError: Error, LocalizedError {
    case apiKeyNotConfigured
    case invalidResponse
    case networkError
    case timeout
    case invalidAPIKey
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "OpenAI API key is not configured. Please configure your API key in the menu bar."
        case .invalidResponse:
            return "Received an invalid response from OpenAI."
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
