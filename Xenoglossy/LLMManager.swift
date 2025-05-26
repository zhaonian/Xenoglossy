import Foundation
import SwiftUI

enum LLMProviderType: String, CaseIterable {
    case openAI = "OpenAI"
    case gemini = "Gemini"
}

class LLMManager: ObservableObject {
    static let shared = LLMManager()
    
    @Published var selectedProvider: LLMProviderType = .openAI {
        didSet {
            print("Provider changed from \(oldValue) to \(selectedProvider)")
            if oldValue != selectedProvider {
                switchProvider(to: selectedProvider)
            }
        }
    }
    
    private var currentProvider: LLMProvider
    
    private init() {
        // Default to Gemini
        currentProvider = GeminiProvider()
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
        print("Switched to provider: \(currentProvider)")
        UserDefaults.standard.set(type.rawValue, forKey: "selectedProvider")
    }
    
    func transformText(_ text: String, tone: Tone) async throws -> String {
        return try await currentProvider.transformText(text, tone: tone)
    }
} 
