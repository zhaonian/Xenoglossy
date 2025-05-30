import Foundation
import Carbon
import AppKit
import SwiftUI

// Helper function to create a four-character code
private func fourCharCode(_ string: String) -> OSType {
    var result: OSType = 0
    if let data = string.data(using: .ascii) {
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            for i in 0..<min(4, data.count) {
                result = result << 8 + OSType(ptr[i])
            }
        }
    }
    return result
}

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    
    private var eventHandler: EventHandlerRef?
    private let shortcutKey = UInt32(kVK_ANSI_X)
    private let modifierFlags = UInt32(controlKey)
    private let source = CGEventSource(stateID: .hidSystemState)
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var llmManager = LLMManager.shared
    
    private init() {}
    
    func registerShortcut() {
        var eventType = EventTypeSpec()
        eventType.eventClass = UInt32(kEventClassKeyboard)
        eventType.eventKind = UInt32(kEventHotKeyPressed)
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                KeyboardShortcutManager.shared.handleHotKey()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = fourCharCode("XENO")
        hotKeyID.id = UInt32(1)
        
        RegisterEventHotKey(
            shortcutKey,
            modifierFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHandler
        )
    }
    
    func handleHotKey() {
        // Check permissions first
        if !AccessibilityManager.shared.isTrusted() {
            DispatchQueue.main.async {
                AccessibilityManager.shared.checkPermissions()
            }
            return
        }

        // Select all text
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x00, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x00, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
        
        // Copy selected text
        let copyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        let copyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        copyDown?.flags = .maskCommand
        copyUp?.flags = .maskCommand
        copyDown?.post(tap: .cghidEventTap)
        copyUp?.post(tap: .cghidEventTap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            // Get the current pasteboard
            let pasteboard = NSPasteboard.general
            
            // Get the current selected text
            if let selectedText = pasteboard.string(forType: .string), !selectedText.isEmpty {
                // Transform the text using the selected LLM provider
                Task {
                    do {
                        let transformedText = try await llmManager.transformText(selectedText, tone: appState.selectedTone)
                        
                        // Set the new text back to the pasteboard
                        pasteboard.clearContents()
                        pasteboard.setString(transformedText, forType: .string)
                        
                        // Paste the transformed text
                        let pasteDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
                        let pasteUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
                        pasteDown?.flags = .maskCommand
                        pasteUp?.flags = .maskCommand
                        pasteDown?.post(tap: .cghidEventTap)
                        pasteUp?.post(tap: .cghidEventTap)
                    } catch {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Error"
                            alert.informativeText = error.localizedDescription
                            alert.alertStyle = .warning
                            
                            if case .apiKeyNotConfigured = error as? LLMError {
                                alert.addButton(withTitle: "Configure API Key")
                                alert.addButton(withTitle: "Cancel")
                                
                                if alert.runModal() == .alertFirstButtonReturn {
                                    // Post notification to show API key configuration
                                    NotificationCenter.default.post(name: .showAPIKeyConfig, object: nil)
                                }
                            } else {
                                alert.addButton(withTitle: "OK")
                                alert.runModal()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func cleanup() {
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }
}
