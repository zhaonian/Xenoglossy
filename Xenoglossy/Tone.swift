import Foundation

enum Tone: String, CaseIterable {
    case professional = "Professional"
    case casual = "Casual"
    case formal = "Formal"
    case friendly = "Friendly"
    case academic = "Academic"    
    case flirting = "Flirting"
    case romantic = "Romantic"
    
    var prompt: String {
        switch self {
        case .professional:
            return "Transform the following text to be more professional while keeping the original meaning and language:"
        case .casual:
            return "Transform the following text to be more casual and conversational while keeping the original meaning and language:"
        case .formal:
            return "Transform the following text to be more formal and business-like while keeping the original meaning and language:"
        case .friendly:
            return "Transform the following text to be more friendly and approachable while keeping the original meaning and language:"
        case .academic:
            return "Transform the following text to be more academic and scholarly while keeping the original meaning and language:"
        case .flirting:
            return "Transform the following text to be more flirting while keeping the original meaning and language:"
        case .romantic:
            return "Transform the following text to be more romantic while keeping the original meaning and language:"
        }
    }
} 
