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
    var predicatedFutureState:WebexState?
    var statusTimer:Timer?
    var timeoutInterval:Double = 0.1

    public func startPolling(){
        
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(timeInterval: timeoutInterval,
                                           target: self,
                                           selector: #selector(updateState),
                                           userInfo: nil,
                                           repeats: false)
    }
    
    public func mute() {
        
        // Make sure Webex is active and mutable
        if ( webexState != .stateActiveNotMuted ) { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.runScript(scriptName: "webex-mute-fast")
        }
        
        // Shh.... need to to find a better workaround for this
        setPredictedFutureState(newFutureState: .stateActiveMuted)
        
    }
    
    public func unmute() {
        
        // Make sure Webex is active and un-mutable
        if ( webexState != .stateActiveMuted ) { return }

        DispatchQueue.global(qos: .userInteractive).async {
            self.runScript(scriptName: "webex-unmute-fast")
        }
        
        // Shh.... need to to find a better workaround for this
        setPredictedFutureState(newFutureState: .stateActiveNotMuted)
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
    
    @objc func updateState() {

        DispatchQueue.global(qos: .utility).async {

            let newStateString = self.runScript(scriptName: "webex-status-fast")
            let newState = WebexState(rawValue: newStateString)!
            
            DispatchQueue.main.async {
                
                // Check if we've reached the predicated future state.
                if (self.predicatedFutureState == newState ) {
                    self.predicatedFutureState = nil
                }
                
                if ( self.webexState != newState && self.predicatedFutureState == nil) {
                        self.setState(newState:newState)
                }
                
                self.startPolling()
            }
        }
    }
    
    private func setPredictedFutureState(newFutureState:WebexState) {
        predicatedFutureState = newFutureState
        setState(newState: predicatedFutureState!)
    }
    
    private func setState(newState:WebexState) {

        webexState = newState
        NotificationCenter.default.post(name: .didChangeWebexState, object: nil)
        
        // Adjust polling timeout if webex isn't open/active.
        switch webexState {
            case .stateActiveMuted:
                timeoutInterval = 0.1
            case .stateActiveNotMuted:
                timeoutInterval = 0.1
            case .stateInactiveNotRunning:
                timeoutInterval = 4.0
            case .stateInactiveNoMeeting:
                timeoutInterval = 1.0
            case .stateError: break
        }
    }
    
    @discardableResult
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
