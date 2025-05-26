import Foundation
import GoogleGenerativeAI

class GeminiProvider: LLMProvider {
    private var model: GenerativeModel?
    
    var isConfigured: Bool {
        return model != nil
    }
    
    func configure(apiKey: String) {
        let config = GenerationConfig(
            temperature: 0.7,
            topP: 0.8,
            topK: 40,
            maxOutputTokens: 1024
        )
        
        // For local development, use the provided apiKey
        // For Xcode Cloud, use the environment variable
        let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? apiKey

        model = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: apiKey,
            generationConfig: config
        )
    }
    
    func removeConfiguration() {
        model = nil
    }
    
    func transformText(_ text: String, tone: Tone) async throws -> String {
        guard let model = model else {
            throw LLMError.apiKeyNotConfigured
        }
        
        let prompt = """
        \(tone.prompt)
        IMPORTANT: Keep the exact same language as the input text. Do not translate or change the language.
        Only return the transformed text. If you cannot transform just return the original text.
        
        \(text)
        """
        
        do {
            let response = try await model.generateContent(prompt)
            guard let responseText = response.text else {
                throw LLMError.invalidResponse
            }
            
            return responseText
        } catch {
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet:
                    throw LLMError.networkError
                case .timedOut:
                    throw LLMError.timeout
                default:
                    throw LLMError.networkError
                }
            }
            
            throw LLMError.unknown(error.localizedDescription)
        }
    }
} 
