import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var selectedTone: Tone = .professional
    
    private init() {}
} 