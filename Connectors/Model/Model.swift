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

protocol Node: AnyObject {
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
            let p = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
            p.lineWidth = 1
            return p
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
            p.move(to: fromBox.anchor)
            p.line(to: toBox.anchor)
            p.lineWidth = CGFloat(lineWidth)
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
        let p = path.cgPath
        let p2 = p.copy(strokingWithWidth: CGFloat(lineWidth), lineCap:.round, lineJoin: .round, miterLimit: 1)
        return p2.contains(point)
    }

    static func == (lhs: Connector, rhs: Connector) -> Bool {
        return lhs.fromBox.id == rhs.fromBox.id && lhs.toBox.id == rhs.toBox.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromBox)
        hasher.combine(toBox)
    }
}
