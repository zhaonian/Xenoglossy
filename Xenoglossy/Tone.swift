import Foundation

enum Tone: String, CaseIterable {
    case professional = "Professional"
    case casual = "Casual"
    case formal = "Formal"
    case friendly = "Friendly"
    case academic = "Academic"    
    case flirting = "Flirting"
    case romantic = "Romantic"
    
    var systemPrompt: String {
        switch self {
        case .professional:
            return "Transform text to be more professional while keeping the original meaning and language."
        case .casual:
            return "Transform text to be more casual and conversational while keeping the original meaning and language."
        case .formal:
            return "Transform text to be more formal and business-like while keeping the original meaning and language."
        case .friendly:
            return "Transform text to be more friendly and approachable while keeping the original meaning and language."
        case .academic:
            return "Transform text to be more academic and scholarly while keeping the original meaningand language."
        case .flirting:
            return "Transform text to be more flirting while keeping the original meaning and language."
        case .romantic:
            return "Transform text to be more romantic while keeping the original meaning and language."
        }
    }
    
    var userPrompt: String {
        switch self {
        case .professional:
            return "Make this text more professional:"
        case .casual:
            return "Make this text more casual:"
        case .formal:
            return "Make this text more formal:"
        case .friendly:
            return "Make this text more friendly:"
        case .academic:
            return "Make this text more academic:"
        case .flirting:
            return "Make this text more flirting:"
        case .romantic:
            return "Make this text more romantic:"
        }
    }
} 
