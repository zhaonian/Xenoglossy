//
//  XenoglossyApp.swift
//  Xenoglossy
//
//  Created by Zhaonian Luan on 5/13/25.
//

import SwiftUI

extension Notification.Name {
    static let showAPIKeyConfig = Notification.Name("showAPIKeyConfig")
}

@main
struct XenoglossyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var llmManager = LLMManager.shared
    @StateObject private var appState = AppState.shared
    @State private var showingAPIKeyConfig = false
    
    var body: some Scene {
        MenuBarExtra("Xenoglossy", systemImage: "wand.and.stars") {
            if llmManager.isConfigured {
                Button("Change API Key") {
                    showConfigWindow()
                }
            } else {
                Button("Configure API Key") {
                    showConfigWindow()
                }
            }
            
            Divider()
            
            Text("Tone")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(Tone.allCases, id: \.self) { tone in
                Button(action: {
                    appState.selectedTone = tone
                }) {
                    if tone == appState.selectedTone {
                        Text("\(tone.rawValue) ✓")
                    } else {
                        Text(tone.rawValue)
                    }
                }
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    private func showConfigWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "LLM API Key Configuration"
        window.contentView = NSHostingView(rootView: APIKeyConfigView(window: window))
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        KeyboardShortcutManager.shared.registerShortcut()
        
        // Set up notification observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowAPIKeyConfig),
            name: .showAPIKeyConfig,
            object: nil
        )
    }
    
    @objc private func handleShowAPIKeyConfig() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "LLM API Key Configuration"
        window.contentView = NSHostingView(rootView: APIKeyConfigView(window: window))
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        KeyboardShortcutManager.shared.cleanup()
    }
}
