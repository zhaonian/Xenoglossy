import Foundation
import SwiftUI

enum LLMProviderType: String, CaseIterable {
    case openAI = "OpenAI"
    case gemini = "Gemini"
}

class LLMManager: ObservableObject {
    static let shared = LLMManager()
    
    @Published var isConfigured: Bool = false
    @Published var selectedProvider: LLMProviderType = .openAI {
        didSet {
            print("Provider changed from \(oldValue) to \(selectedProvider)")
            if oldValue != selectedProvider {
                switchProvider(to: selectedProvider)
            }
        }
    }
    
    private var currentProvider: LLMProvider
    private let keychainService = "io.zluan.xenoglossy"
    
    private init() {
        // Default to OpenAI
        currentProvider = OpenAIProvider()
        loadSavedProvider()
    }
    
    private func loadSavedProvider() {
        if let savedProvider = UserDefaults.standard.string(forKey: "selectedProvider"),
           let provider = LLMProviderType(rawValue: savedProvider) {
            print("Loading saved provider: \(provider)")
            selectedProvider = provider
            switchProvider(to: provider)
        }
    }
    
    func switchProvider(to type: LLMProviderType) {
        print("Switching to provider: \(type)")
        switch type {
        case .openAI:
            currentProvider = OpenAIProvider()
        case .gemini:
            currentProvider = GeminiProvider()
        }
        
        // Load saved API key for the new provider
        if let apiKey = getApiKey(for: type) {
            print("Found saved API key for \(type)")
            currentProvider.configure(apiKey: apiKey)
        } else {
            print("No saved API key found for \(type)")
        }
        
        isConfigured = currentProvider.isConfigured
        print("Provider switched. isConfigured: \(isConfigured)")
        UserDefaults.standard.set(type.rawValue, forKey: "selectedProvider")
    }
    
    func configure(apiKey: String) {
        print("Configuring \(selectedProvider) with new API key")
        currentProvider.configure(apiKey: apiKey)
        saveApiKey(apiKey, for: selectedProvider)
        isConfigured = currentProvider.isConfigured
        print("Configuration complete. isConfigured: \(isConfigured)")
    }
    
    func transformText(_ text: String, tone: Tone) async throws -> String {
        return try await currentProvider.transformText(text, tone: tone)
    }
    
    // MARK: - Keychain Management
    
    private func saveApiKey(_ key: String, for provider: LLMProviderType) {
        print("Saving API key for \(provider)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: provider.rawValue,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessGroup as String: "io.zluan.xenoglossy"
        ]
        
        // First try to delete any existing key for this provider
        SecItemDelete(query as CFDictionary)
        
        // Then add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving API key for \(provider.rawValue): \(status)")
        } else {
            print("Successfully saved API key for \(provider)")
        }
    }
    
    private func getApiKey(for provider: LLMProviderType) -> String? {
        print("Getting API key for \(provider)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: provider.rawValue,
            kSecReturnData as String: true,
            kSecAttrAccessGroup as String: "io.zluan.xenoglossy"
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let key = String(data: data, encoding: .utf8) {
            print("Found API key for \(provider)")
            return key
        }
        print("No API key found for \(provider)")
        return nil
    }
    
    func removeApiKey(for provider: LLMProviderType) {
        print("Removing API key for \(provider)")
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: provider.rawValue,
            kSecAttrAccessGroup as String: "io.zluan.xenoglossy"
        ]
        
        SecItemDelete(query as CFDictionary)
        
        // Only remove configuration if this is the current provider
        if provider == selectedProvider {
            currentProvider.removeConfiguration()
            isConfigured = false
            print("Removed configuration for current provider")
        }
    }
    
    func removeAllApiKeys() {
        print("Removing all API keys")
        for provider in LLMProviderType.allCases {
            removeApiKey(for: provider)
        }
        currentProvider.removeConfiguration()
        isConfigured = false
    }
} 
