//
//  SerialManager.swift
//  WebEx-Mute-Button
//
//  Created by Jon Reiling on 5/3/20.
//  Copyright © 2020 Jon Reiling. All rights reserved.
//

import Foundation
import ORSSerial

extension Notification.Name {
    static let didPressExternalButton = Notification.Name("didPressExternalButton")
    static let didPortUpdate = Notification.Name("portUpdate")
}

enum ExternalStatusButtonState:String {
    case statusInactive = "s0"
    case statusActiveGreen = "s1"
    case statusActiveRed = "s2"
}

class ExternalStatusButtonManager:NSObject, ORSSerialPortDelegate  {
    
    static let shared = ExternalStatusButtonManager()
    var serialPort:ORSSerialPort?
        
    override init() {

        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePortsAdded(_:)), name: .ORSSerialPortsWereConnected, object: nil)
    }
    
    @discardableResult
    public func connectToPath(path:String) -> Bool {
        
        // Check to make sure the path is valid
        if ( !checkIfPathIsValid(path: path ) ) {
            return false
        }
        
        // Open the port
        serialPort = ORSSerialPort(path: path)
        serialPort?.baudRate = 9600
        serialPort?.delegate = self
        serialPort?.open()
                
        return true
    }
    
    @discardableResult
    public func reconnect() -> Bool {
        
        // See if the port we connected to last time is available.
        if let previousPort = UserDefaults.standard.string(forKey: "preferredPort") {
            return connectToPath(path: previousPort)
        }

        return false
    }
    
    public func setButtonState( state:ExternalStatusButtonState ) {

        sendSerialCommand(command: state.rawValue)
    }
    
    public func disconnect() {
  
        setButtonState(state: .statusInactive)
        serialPort?.close()
        serialPort = nil
    }
    
    public func ports() -> Array<ORSSerialPort> {
        
        return ORSSerialPortManager.shared().availablePorts
    }
    
    public func isConnected() -> Bool {
        
        return (serialPort?.isOpen ?? false)
    }
    
    private func sendSerialCommand(command:String){
        
        let dataToSend = command.data(using: .utf8)
        serialPort?.send(dataToSend!)
    }
    
    private func checkIfPathIsValid( path:String ) -> Bool {
        
        let ports = self.ports()
        
        for port in ports {
            if port.path == path {
                return true
            }
        }
        return false
    }
    
    private func evaluateButtonValue( value:String ) {

        // Check and see what the microcontroller just sent us.
        if (value == "Press"){
            NotificationCenter.default.post(name: .didPressExternalButton, object: nil)
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        
        let string = String(data: data, encoding: .utf8)!
        evaluateButtonValue(value: string)
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        
        // Save the successfully opened port for re-use in the future
        UserDefaults.standard.set(serialPort.path, forKey: "preferredPort")
        NotificationCenter.default.post(name: .didPortUpdate, object: nil)
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        
        NotificationCenter.default.post(name: .didPortUpdate, object: nil)
        self.disconnect()
    }
        
    @objc func handlePortsAdded(_ notification:Notification) {
        
        let _ = reconnect()
        NotificationCenter.default.post(name: .didPortUpdate, object: nil)
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        
        if (serialPort.path == self.serialPort?.path) {
            disconnect()
        }
        NotificationCenter.default.post(name: .didPortUpdate, object: nil)
    }

    
}
