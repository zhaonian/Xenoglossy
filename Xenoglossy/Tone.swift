import Foundation

enum Tone: String, CaseIterable {
    case professional = "Professional"
    case casual = "Casual"
    case friendly = "Friendly"
    case academic = "Academic"    
    case flirting = "Flirting"
    case romantic = "Romantic"
    case gaslighting = "Gaslighting"
    case motivational = "Motivational"
    case grammar = "Grammar Check"
    case genZ = "Gen Z"
    case boomer = "Boomer"

    var prompt: String {
        switch self {
        case .professional:
            return "Transform the following text to be more professional while keeping the original meaning and language:"
        case .casual:
            return "Transform the following text to be more casual and conversational while keeping the original meaning and language:"
        case .friendly:
            return "Transform the following text to be more friendly and approachable while keeping the original meaning and language:"
        case .academic:
            return "Transform the following text to be more academic and scholarly while keeping the original meaning and language:"
        case .flirting:
            return "Transform the following text to be more flirting while keeping the original meaning and language:"
        case .romantic:
            return "Transform the following text to be more romantic while keeping the original meaning and language:"
        case .gaslighting:
            return "Transform the following text to be more gaslighting and manipulative, making the recipient question their reality while keeping the original meaning and language:"
        case .motivational:
            return "Transform the following text to be extremely motivational and inspiring, using powerful and energetic language while keeping the original meaning and language:"
        case .grammar:
            return "Fix grammar and spelling while preserving the original language and meaning:"
        case .genZ:
            return "Rewrite the following text in an exaggerated Gen Z style. Use lots of internet slang, memes, abbreviations, and emojis. Make it super playful and dramatic—like a viral TikTok comment."
        case .boomer:
            return "Rewrite the following text in an exaggerated Boomer style. Use very formal, old-fashioned, and polite language. Avoid all modern slang. Make it sound like advice from a grandparent."
        }
    }
} 
