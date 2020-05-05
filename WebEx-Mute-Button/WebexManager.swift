//
//  WebExStatusManager.swift
//  WebEx-Mute-Button
//
//  Created by Jon Reiling on 5/3/20.
//  Copyright © 2020 Jon Reiling. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let willChangeWebexState = Notification.Name("willChangeWebexState")
    static let didChangeWebexState = Notification.Name("didChangeWebexState")
}

enum WebexState:String {
    case stateInactiveNotRunning = "inactive-not-running"
    case stateInactiveNoMeeting = "inactive-no-meeting"
    case stateActiveMuted = "active-muted"
    case stateActiveNotMuted = "active-not-muted"
    case stateError = "error"
}

class WebexManager:NSObject  {
  
    static let shared = WebexManager()
    var webexState:WebexState = .stateInactiveNotRunning
    var statusTimer:Timer?

    public func startPolling(timeout:Double = 0.4){
        
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: true, block: { _ in
             self.updateState()
         })
        
    }
    
    public func mute() {
        
        // Make sure Webex is active and mutable
        if ( webexState != .stateActiveNotMuted ) { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let _ = self.runScript(scriptName: "webex-mute-fast")
        }
        
        // Shh.... need to implement as willChangeWebexState
        ExternalStatusButtonManager.shared.setButtonState(state: .statusActiveRed)
    }
    
    public func unmute() {
        
        // Make sure Webex is active and un-mutable
        if ( webexState != .stateActiveMuted ) { return }

        DispatchQueue.global(qos: .userInteractive).async {
            let _ = self.runScript(scriptName: "webex-unmute-fast")
        }

        // Shh.... need to implement as willChangeWebexState
        ExternalStatusButtonManager.shared.setButtonState(state: .statusActiveGreen)
    }
    
    public func toggleMute() {
        
        switch webexState {

        case .stateActiveMuted: unmute()
        case .stateActiveNotMuted: mute()
        case .stateInactiveNotRunning: break
        case .stateInactiveNoMeeting: break
        case .stateError: break
        }
        
    }
    
    func updateState() {

        DispatchQueue.global(qos: .userInteractive).async {
            
            let newStateString = self.runScript(scriptName: "webex-status-fast")
            let newState = WebexState(rawValue: newStateString)!
            
            if ( self.webexState != newState ) {
                DispatchQueue.main.async {
                    self.setState(newState:newState)
                }
            }
        }
    }
    
    private func setState(newState:WebexState) {

        webexState = newState
        NotificationCenter.default.post(name: .didChangeWebexState, object: nil)
        
        // Adjust polling timeout if webex isn't open/active.
        switch webexState {
            case .stateActiveMuted:
                startPolling(timeout:0.25)
            case .stateActiveNotMuted:
                startPolling(timeout:0.25)
            case .stateInactiveNotRunning:
                startPolling(timeout:4.0)
            case .stateInactiveNoMeeting:
                startPolling(timeout:1.0)
            case .stateError: break
        }
    }
    
    private func runScript(scriptName:String) -> String{
        
        let statusScript = Bundle.main.url(forResource: scriptName, withExtension: "scpt")!
        
        guard let script = NSAppleScript(contentsOf: statusScript, error: nil)
            else { return "error" }
        
        /*var error:NSDictionary?
        if let output: NSAppleEventDescriptor = script.executeAndReturnError(&error){
           return output.stringValue!
        } else if (error != nil) {
            print("error: \(error!)")
        }*/
        
        var error:NSDictionary?
         let output: NSAppleEventDescriptor = script.executeAndReturnError(&error)
        
        if (error != nil) {
            print("error: \(error!)")
            return "error"
        }
        
        return output.stringValue!

    }
}
