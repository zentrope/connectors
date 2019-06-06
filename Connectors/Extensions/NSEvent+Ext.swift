//
//  NSEvent+Ext.swift
//  Connectors
//
//  Created by Keith Irwin on 6/5/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

extension NSEvent {
    func place(_ view: NSView) -> NSPoint {
        return view.convert(locationInWindow, from: nil)
    }
}
