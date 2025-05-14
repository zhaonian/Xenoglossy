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
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Set the icon and behavior
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gear", accessibilityDescription: "Xenoglossy")
        }
        
        // Create a menu for the status bar item
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(quitApp), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
