import SwiftUI
import AppKit

struct APIKeyConfigView: View {
    @StateObject private var llmManager = LLMManager.shared
    let window: NSWindow
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Model")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(LLMProviderType.allCases, id: \.self) { provider in
                    Button(action: {
                        llmManager.selectedProvider = provider
                    }) {
                        HStack {
                            Image(systemName: llmManager.selectedProvider == provider ? "circle.fill" : "circle")
                                .foregroundColor(.accentColor)
                            Text(provider.rawValue)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
                        
            Text("""
                Select a tone from the menu bar icon. 
                Use ⌃ + X (ctrl + X) to transform text.
            """)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            Button(action: {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }) {
                HStack {
                    Image(systemName: "lock.shield")
                    Text("Open Accessibility Settings")
                }
            }
            .buttonStyle(.bordered)
            .help("Open System Settings to grant accessibility permissions")
        }
        .padding()
        .frame(width: 500, height: 280)
    }
}

#Preview {
    APIKeyConfigView(window: NSWindow())
} 
