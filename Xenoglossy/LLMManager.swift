import Foundation
import SwiftUI

enum LLMProviderType: String, CaseIterable {
    case gemini = "Gemini-flash-2.0"
    case openAI = "OpenAI-gpt-4.1-nano"
}

class LLMManager: ObservableObject {
    static let shared = LLMManager()
    
    @Published var selectedProvider: LLMProviderType = .gemini {
        didSet {
            if oldValue != selectedProvider {
                UserDefaults.standard.set(selectedProvider.rawValue, forKey: "selectedProvider")
            }
        }
    }
    
    private init() {
        loadSavedProvider()
    }
    
    private func loadSavedProvider() {
        if let savedProvider = UserDefaults.standard.string(forKey: "selectedProvider"),
           let provider = LLMProviderType(rawValue: savedProvider) {
            selectedProvider = provider
        }
    }
    
    func transformText(_ text: String, tone: Tone) async throws -> String {
        let provider: LLMProvider = switch selectedProvider {
        case .openAI:
            OpenAIProvider()
        case .gemini:
            GeminiProvider()
        }
        return try await provider.transformText(text, tone: tone)
    }
} 
