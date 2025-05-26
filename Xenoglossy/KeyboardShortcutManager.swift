import Foundation
import Carbon
import AppKit

class KeyboardShortcutManager {
    private var eventHandler: EventHandlerRef?
    private let source = CGEventSource(stateID: .hidSystemState)
    
    func registerShortcut() {
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        // Create the hot key
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4D45) // 'ME'
        hotKeyID.id = UInt32(1)
        
        // Register the hot key (Ctrl + Cmd + 1)
        var hotKeyRef: EventHotKeyRef?
        RegisterEventHotKey(
            UInt32(kVK_ANSI_1),
            UInt32(controlKey | cmdKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        // Install the event handler
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, eventRef, _) -> OSStatus in
                KeyboardShortcutManager.shared.handleHotKey()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
    }
    
    func handleHotKey() {
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
                // Transform the text using OpenAI
                Task {
                    do {
                        let transformedText = try await OpenAIManager.shared.transformText(selectedText)
                        
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
                    } catch let error as OpenAIError {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Error"
                            alert.informativeText = error.localizedDescription
                            alert.alertStyle = .warning
                            
                            if case .invalidAPIKey = error {
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
                    } catch {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Error"
                            alert.informativeText = "An unexpected error occurred: \(error.localizedDescription)"
                            alert.alertStyle = .warning
                            alert.addButton(withTitle: "OK")
                            alert.runModal()
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
    
    // Singleton instance
    static let shared = KeyboardShortcutManager()
    private init() {}
} 
