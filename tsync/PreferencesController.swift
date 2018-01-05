//
//  PreferencesController.swift
//  tsync
//
//  Created by Scott Sword on 11/22/17.
//  Copyright © 2017 Scott Sword. All rights reserved.
//

import Cocoa
import AppKit

class PreferencesController: NSWindowController {
    
    convenience init() {
        self.init(windowNibName: "PreferencesController")
    }

    @IBOutlet weak var PathInput: NSTextField!
    @IBOutlet weak var LoadingLabel: NSTextField!

    @IBAction func saveClicked(_ sender: NSButton) {
        
        // Save to tsync bash script
        let text: String = self.PathInput.stringValue
        UserDefaults.standard.set(text, forKey: "bashPath")
        
        
        // Enable tsync toggle
        let appDelegate = NSApplication.shared().delegate as? AppDelegate
        
        if text != "" {
            appDelegate?.enableTsyncToggleButton(enableTsync: true)
        }
        
        print("Bash path " + text + " saved.")
        
        // Show success message
        LoadingLabel?.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500)) {
            self.LoadingLabel?.isHidden = true
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        var defaultInputValue: String = ""
        let savedBashPath = UserDefaults.standard.string(forKey: "bashPath")
        
        if savedBashPath != nil && savedBashPath != "" {
            defaultInputValue = savedBashPath!
        } else {
            defaultInputValue = "Bash path"
        }

        PathInput.stringValue = defaultInputValue

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        
        LoadingLabel?.isHidden = true
    }
    
}
