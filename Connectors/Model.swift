//
//  Model.swift
//  Connectors
//
//  Created by Keith Irwin on 6/3/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

enum Shape {
    case box
    case connector
}

protocol Node {
    var id : String { get }
    var path: NSBezierPath { get }
    var type: Shape { get }
    func contains(_ point: NSPoint) -> Bool
}

class Box: Node, Hashable {

    let id: String = UUID().uuidString
    private var position: NSPoint
    private var size = NSSize(width: 100, height: 66)

    let type = Shape.box
    var rect: CGRect { return CGRect(origin: position, size: size) }

    var path: NSBezierPath {
        get {
            return NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        }
    }

    var anchor: NSPoint {
        return NSMakePoint(rect.minX + (rect.width / 2), rect.minY + (rect.height / 2))
    }

    init(origin: NSPoint) {
        self.position = origin
    }

    func moveTo(_ position: NSPoint) {
        self.position = position
    }

    func contains(_ point: NSPoint) -> Bool {
        return path.contains(point)
    }

    static func == (lhs: Box, rhs: Box) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class Connector: Node, Hashable {

    let id = UUID().uuidString
    let type = Shape.connector

    var path: NSBezierPath {
        get {
            let p = NSBezierPath()
            let x0 = fromBox.anchor.x
            let y0 = fromBox.anchor.y
            let x1 = toBox.anchor.x
            let y1 = toBox.anchor.y

            var dx = Double(x1 - x0)
            var dy = Double(y1 - y0)
            let len = sqrt(dx * dx + dy * dy)

            dx = dx / len
            dy = dy / len

            let px = CGFloat(lineWidth / 2 * (-dy))
            let py = CGFloat(lineWidth / 2 * dx)

            p.move(to: NSMakePoint(x0 + px, y0 + py))
            p.line(to: NSMakePoint(x1 + px, y1 + py))
            p.line(to: NSMakePoint(x1 - px, y1 - py))
            p.line(to: NSMakePoint(x0 - px, y0 - py))
            p.close()
            return p
        }
    }

    private(set) var fromBox: Box
    private(set) var toBox: Box

    private let lineWidth : Double

    init(fromBox: Box, toBox: Box, lineWidth: Double = 2) {
        self.fromBox = fromBox
        self.toBox = toBox
        self.lineWidth = lineWidth
    }

    func contains(_ point: NSPoint) -> Bool {
        return path.contains(point)
    }

    static func == (lhs: Connector, rhs: Connector) -> Bool {
        return lhs.fromBox.id == rhs.fromBox.id && lhs.toBox.id == rhs.toBox.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromBox)
        hasher.combine(toBox)
    }
}
