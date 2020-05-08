//
//  AppDelegate.swift
//  WebEx-Mute-Button
//
//  Created by Jon Reiling on 5/2/20.
//  Copyright © 2020 Jon Reiling. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var activity: NSObjectProtocol?
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    var menuItemStatus:NSMenuItem?
    var menuItemMute:NSMenuItem?
    var menuItemUnmute:NSMenuItem?
    var menuItemPorts:NSMenuItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // Hack to keep the app responsive in the background.
        activity = ProcessInfo().beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "Good Reason")
        
        // Set up webex manager
        WebexManager.shared.startPolling()
        NotificationCenter.default.addObserver(self, selector: #selector(onWebexStateChange(_:)), name: .didChangeWebexState, object: nil)

        // Set up external button manager
        ExternalStatusButtonManager.shared.reconnect()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePortsSubMenu(_:)), name: .didPortUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onExternalButtonPress(_:)), name: .didPressExternalButton, object: nil)
        
        // Construct our menu items
        constructMenu()
    }
    
    func constructMenu() {
        
        // Build our menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        // Status is never enabled.
        menuItemStatus = NSMenuItem(title: "Status", action: nil, keyEquivalent: "")
        menuItemStatus?.isEnabled = false
        menu.addItem(menuItemStatus!)

        menu.addItem(NSMenuItem.separator())

        menuItemMute = NSMenuItem(title: "Mute", action: #selector(toggleMute(_:)), keyEquivalent: "")
        menu.addItem(menuItemMute!)
        
        menuItemUnmute = NSMenuItem(title: "Unmute", action: #selector(toggleMute(_:)), keyEquivalent: "")
        menu.addItem(menuItemUnmute!)

        menu.addItem(NSMenuItem.separator())

        menuItemPorts = NSMenuItem(title: "Button Status", action: nil, keyEquivalent: "")
        menu.addItem(menuItemPorts!)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        
        onWebexStateChange()
        updatePortsSubMenu()
    }
    
    @objc func toggleMute(_ sender: AnyObject?) {
        
        WebexManager.shared.toggleMute()
    }

    @objc func onWebexStateChange(_ notification:Notification? = nil) {

        menuItemStatus?.title = NSLocalizedString(WebexManager.shared.webexState.rawValue, comment:"")
        
        switch WebexManager.shared.webexState {
            
        case .stateInactiveNotRunning:
            self.statusItem.button?.image = NSImage(named: "Icon")
            menuItemUnmute?.isEnabled = false
            menuItemMute?.isEnabled = false
            ExternalStatusButtonManager.shared.setButtonState(state: .statusInactive)
        case .stateInactiveNoMeeting:
            self.statusItem.button?.image = NSImage(named: "Icon")
            menuItemUnmute?.isEnabled = false
            menuItemMute?.isEnabled = false
            ExternalStatusButtonManager.shared.setButtonState(state: .statusInactive)
        case .stateActiveMuted:
            self.statusItem.button?.image = NSImage(named: "Icon-Muted")
            menuItemUnmute?.isEnabled = true
            menuItemMute?.isEnabled = false
            ExternalStatusButtonManager.shared.setButtonState(state: .statusActiveRed)
        case .stateActiveNotMuted:
            self.statusItem.button?.image = NSImage(named: "Icon-Unmuted")
            menuItemUnmute?.isEnabled = false
            menuItemMute?.isEnabled = true
            ExternalStatusButtonManager.shared.setButtonState(state: .statusActiveGreen)
        case .stateError:
            break
        }
    }
    
    @objc func onExternalButtonPress(_ notification:Notification) {
        
        WebexManager.shared.toggleMute()
    }
    
    @objc func updatePortsSubMenu(_ notification:Notification? = nil) {
            
        let ports = ExternalStatusButtonManager.shared.ports()
        let path = ExternalStatusButtonManager.shared.serialPort?.path
        let subMenu = NSMenu()
                
        for port in ports {
            let portMenuItem = NSMenuItem(title: port.path, action: #selector(connectToPort(_:)), keyEquivalent: "")
            portMenuItem.state = ( path == port.path ) ? .on : .off
            subMenu.addItem(portMenuItem)
        }
        
        menuItemPorts?.title = ( path != nil ) ? "Button: Connected" : "Button: Not Connected"
        menuItemPorts?.submenu = subMenu
    }
    
    @objc func connectToPort(_ sender: NSMenuItem) {
        
        ExternalStatusButtonManager.shared.connectToPath(path: sender.title)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Insert code here to tear down your application
        ExternalStatusButtonManager.shared.disconnect()
    }
}

