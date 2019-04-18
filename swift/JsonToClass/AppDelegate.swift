//
//  AppDelegate.swift
//  JsonToClass
//
//  Created by pkh on 17/04/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ theApplication: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in theApplication.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        
        return true
    }


}

