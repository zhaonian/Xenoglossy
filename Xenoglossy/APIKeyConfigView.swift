import SwiftUI
import AppKit

struct APIKeyConfigView: View {
    @StateObject private var openAIManager = OpenAIManager.shared
    @State private var apiKey: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    let window: NSWindow
    
    var body: some View {
        VStack(spacing: 20) {
            Text("OpenAI API Key Configuration")
                .font(.headline)
            
            TextField("Enter your OpenAI API key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Save") {
                    if apiKey.isEmpty {
                        alertMessage = "Please enter an API key"
                        showingAlert = true
                    } else {
                        openAIManager.saveApiKey(apiKey)
                        window.close()
                    }
                }
                .keyboardShortcut(.defaultAction)
                
                Button("Cancel") {
                    window.close()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    APIKeyConfigView(window: NSWindow())
} 