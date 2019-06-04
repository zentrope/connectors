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
    //    var id : String { get }
    var path: NSBezierPath { get }
    var type: Shape { get }
    func contains(_ point: NSPoint) -> Bool
}

class Box: Node, Equatable, Hashable {

    private var id: String = UUID().uuidString
    private var position: NSPoint
    private var size = NSSize(width: 100, height: 66)

    let type = Shape.box
    var rect: CGRect { return CGRect(origin: position, size: size) }

    var path: NSBezierPath {
        get {
            return NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        }
    }

    var connectPoint: NSPoint {
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

class Connector: Node, Equatable, Hashable {

    let type = Shape.connector
    private let width = CGFloat(10)

    var path: NSBezierPath {
        get {
            let p = NSBezierPath()
            let x0 = fromBox.connectPoint.x
            let y0 = fromBox.connectPoint.y
            let x1 = toBox.connectPoint.x
            let y1 = toBox.connectPoint.y

            var dx = Double(x1 - x0)
            var dy = Double(y1 - y0)
            let len = sqrt(dx * dx + dy * dy)

            dx = dx / len
            dy = dy / len

            let w = 4.0
            let px = CGFloat(w / 2 * (-dy))
            let py = CGFloat(w / 2 * dx)

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

    init(fromBox: Box, toBox: Box) {
        self.fromBox = fromBox
        self.toBox = toBox
    }

    func contains(_ point: NSPoint) -> Bool {
        return path.contains(point)
    }

    static func == (lhs: Connector, rhs: Connector) -> Bool {
        return lhs.fromBox == rhs.fromBox && lhs.toBox == rhs.toBox
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromBox)
        hasher.combine(toBox)
    }
}
