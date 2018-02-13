//
//  AppDelegate.swift
//  tsync
//
//  Created by Scott Sword on 11/9/17.
//  Copyright © 2017 Scott Sword. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    let preferencesController = PreferencesController()
    
    var currentProcess: Process? = nil
    var isSyncing: Bool = false
    var isTsyncRunning: Bool = false
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var statusLabel: NSMenuItem? = nil
    var tsyncToggle: NSMenuItem? = nil
    
    var isBashPathAvailable: Bool = false
    let savedBashPath = UserDefaults.standard.string(forKey: "bashPath")


    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func startTsync(_ sender: NSMenuItem) {
        
        if isTsyncRunning {
            currentProcess?.terminate()
            let icon = NSImage(named: "statusIconInactive")
            statusItem.title = nil
            statusItem.image = icon
            
            // Set the Label
            self.statusLabel?.title = "tsync: off"
            
            // Set the Option
            self.tsyncToggle?.title = "Turn tsync on"
            
            isTsyncRunning = false
            
            print("Stopping tsync.")
        
        } else {
            print("Saved path is " + savedBashPath!)
            currentProcess = Process()
            currentProcess?.launchPath = savedBashPath
            currentProcess?.arguments = ["dev"]
            let outputPipe = Pipe()
            currentProcess?.standardOutput = outputPipe
            
            let outputHandler = outputPipe.fileHandleForReading
            
            outputHandler.readabilityHandler = { outputPipe in
                if let line = String(data: outputPipe.availableData, encoding: String.Encoding.utf8) {
                    print("tsync output: \(line)")
                    if line.range(of:"Syncing") != nil {
                        print("starting new sync process.")
                        
                        // Set Icon to processing
                        let icon = NSImage(named: "statusIconActive")
                        self.statusItem.image = icon
                        
                    } else if line.range(of:"sent") != nil {
                        print("tsync operation complete.")
                        
                        // Set Icon Back
                        let icon = NSImage(named: "statusIcon")
                        self.statusItem.image = icon
                    } else {
                        print("tsync is still listening...")
                    }
                } else {
                    print("Error decoding data.")
                }
            }
            
            
            // Kick off tsync
            currentProcess?.launch()
            
            // Set Icon
            let icon = NSImage(named: "statusIcon")
            statusItem.title = nil
            statusItem.image = icon
            
            // Set the Label
            self.statusLabel?.title = "tsync: on"
            
            // Set the Option
            self.tsyncToggle?.title = "Turn tsync off"
            
            isTsyncRunning = true
            
            print("Starting tsync.")
        }
        
    }

    @IBAction func LaunchPreferences(_ sender: NSMenuItem) {
        print("Attempted to launch preferences pane.")
        preferencesController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func enableTsyncToggleButton(enableTsync: Bool) {
        if enableTsync {
            self.tsyncToggle?.isEnabled = true
        } else {
            self.tsyncToggle?.isEnabled = false
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let icon = NSImage(named: "statusIconInactive")
        statusItem.title = nil
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Set the Label
        self.statusLabel = statusMenu.item(at: 0)
        self.statusLabel?.title = "tsync: off"
        self.statusLabel?.isEnabled = false

        // Set the Option
        self.tsyncToggle = statusMenu.item(at: 2)
        self.tsyncToggle?.title = "Turn tsync on"
        
        
        // If there is no bash path available disable tsync on
        if savedBashPath != nil && savedBashPath != "" {
            isBashPathAvailable = true
        }

        
        if isBashPathAvailable {
            print("bash path found, enabling tsync toggle")
            enableTsyncToggleButton(enableTsync: true)
        } else {
            print("bash path not found, disabling tsync toggle")
            enableTsyncToggleButton(enableTsync: false)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        currentProcess?.terminate()
    }


}

