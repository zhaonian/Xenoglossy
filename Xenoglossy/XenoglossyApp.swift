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
    
    var body: some Scene {
        MenuBarExtra("Instant Tone Changer", systemImage: "wand.and.stars") {
            Button("Settings") {
                appDelegate.showAPIKeyConfig()
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
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var configWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        KeyboardShortcutManager.shared.registerShortcut()
        
        // Set up notification observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAPIKeyConfig),
            name: .showAPIKeyConfig,
            object: nil
        )
        
        // Create the config window
        createConfigWindow()
        
        // Show API key configuration window on launch
        showAPIKeyConfig()
    }
    
    private func createConfigWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Instant Tone Changer"
        window.contentView = NSHostingView(rootView: APIKeyConfigView(window: window))
        window.isReleasedWhenClosed = false // Keep the window instance alive when closed
        self.configWindow = window
    }
    
    @objc func showAPIKeyConfig() {
        if let window = configWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        KeyboardShortcutManager.shared.cleanup()
    }
}
