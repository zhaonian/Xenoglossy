import SwiftUI
import AppKit

struct APIKeyConfigView: View {
    @StateObject private var llmManager = LLMManager.shared
    @State private var apiKey: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    let window: NSWindow
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LLM API Key Configuration")
                .font(.headline)
            
            Picker("Provider", selection: $llmManager.selectedProvider) {
                ForEach(LLMProviderType.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: llmManager.selectedProvider) { newProvider in
                // Clear the API key field when switching providers
                apiKey = ""
            }
            
            TextField("Enter your \(llmManager.selectedProvider.rawValue) API key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Save") {
                    if apiKey.isEmpty {
                        alertMessage = "Please enter an API key"
                        showingAlert = true
                    } else {
                        llmManager.configure(apiKey: apiKey)
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