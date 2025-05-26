import Foundation
import OpenAI

class OpenAIProvider: LLMProvider {
    private var openAI: OpenAI?
    private let systemInstructions = """
    You are a text transformation assistant. Your task is to transform text according to the given tone while keeping the original meaning and language.
    IMPORTANT: Return ONLY the transformed text without any explanations, options, or additional context.
    """
    
    init() {
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            openAI = OpenAI(apiToken: apiKey)
        } else {
            openAI = OpenAI(apiToken: Config.openAIKey)
        }
    }

    func transformText(_ text: String, tone: Tone) async throws -> String {
        guard let openAI = openAI else {
            throw LLMError.apiKeyNotConfigured
        }
        
        let prompt = """
        \(tone.prompt)
        
        \(text)
        """
        
        do {
            guard let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: systemInstructions),
                  let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
                throw LLMError.invalidResponse
            }
            
            let query = ChatQuery(
                messages: [systemMessage, userMessage],
                model: .gpt4_1_nano
            )
            
            let result = try await openAI.chats(query: query)
            guard let response = result.choices.first?.message.content else {
                throw LLMError.invalidResponse
            }
            
            return response
        } catch let error as LLMError {
            throw error
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
