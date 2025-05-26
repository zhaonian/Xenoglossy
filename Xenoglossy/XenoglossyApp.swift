//
//  XenoglossyApp.swift
//  Xenoglossy
//
//  Created by Zhaonian Luan on 5/13/25.
//

import SwiftUI

@main
struct XenoglossyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("Xenoglossy", systemImage: "pawprint") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Check accessibility permissions
        AccessibilityManager.shared.checkPermissions()
        
        // Register for keyboard shortcut
        KeyboardShortcutManager.shared.registerShortcut()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up the keyboard shortcut manager
        KeyboardShortcutManager.shared.cleanup()
    }
}
