//
//  AppDelegate.swift
//  Connectors
//
//  Created by Keith Irwin on 5/31/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //NSApp.mainWindow?.isMovableByWindowBackground = true
        NSApp.mainWindow?.setContentSize(NSMakeSize(800, 600))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

