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
        // First, try to select the current word or line
        // Press Cmd+A to select all text in the current field
        let cmdADown = CGEvent(keyboardEventSource: source, virtualKey: 0x00, keyDown: true)
        let cmdAUp = CGEvent(keyboardEventSource: source, virtualKey: 0x00, keyDown: false)
        cmdADown?.flags = .maskCommand
        cmdAUp?.flags = .maskCommand
        cmdADown?.post(tap: .cghidEventTap)
        cmdAUp?.post(tap: .cghidEventTap)
        
        // Chain the operations using DispatchQueue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            // Press Cmd+C to copy the selected text
            let cmdCDown = CGEvent(keyboardEventSource: self.source, virtualKey: 0x08, keyDown: true)
            let cmdCUp = CGEvent(keyboardEventSource: self.source, virtualKey: 0x08, keyDown: false)
            cmdCDown?.flags = .maskCommand
            cmdCUp?.flags = .maskCommand
            cmdCDown?.post(tap: .cghidEventTap)
            cmdCUp?.post(tap: .cghidEventTap)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                // Get the current pasteboard
                let pasteboard = NSPasteboard.general
                
                // Get the current selected text
                if let selectedText = pasteboard.string(forType: .string), !selectedText.isEmpty {
                    // Create new text with Meow appended
                    let newText = selectedText + "Meow"
                    
                    // Set the new text back to the pasteboard
                    pasteboard.clearContents()
                    pasteboard.setString(newText, forType: .string)
                    
                    // Press Cmd+V to paste
                    let cmdVDown = CGEvent(keyboardEventSource: self.source, virtualKey: 0x09, keyDown: true)
                    let cmdVUp = CGEvent(keyboardEventSource: self.source, virtualKey: 0x09, keyDown: false)
                    cmdVDown?.flags = .maskCommand
                    cmdVUp?.flags = .maskCommand
                    cmdVDown?.post(tap: .cghidEventTap)
                    cmdVUp?.post(tap: .cghidEventTap)
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
