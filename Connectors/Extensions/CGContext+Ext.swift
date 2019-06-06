//
//  CGContext+Ext.swift
//  Connectors
//
//  Created by Keith Irwin on 6/5/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

extension CGContext {

    func backgroundFill() {
        self.setFillColor(NSColor.controlBackgroundColor.cgColor)
    }

    func accentStroke() {
        self.setStrokeColor(NSColor.controlAccentColor.cgColor)
    }

    func orangeStroke() {
        self.setStrokeColor(NSColor.systemOrange.cgColor)
    }

    func grayStroke() {
        self.setStrokeColor(NSColor.systemGray.cgColor)
    }

    func redStroke() {
        self.setStrokeColor(NSColor.systemRed.cgColor)
    }
}
