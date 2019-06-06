//
//  State.swift
//  Connectors
//
//  Created by Keith Irwin on 6/4/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class State {

    private(set) var boxes = [Box]()
    private(set) var connectors = Set<Connector>()

    let defaultGridSize = 20
    let defaultWidth = CGFloat(500)
    let defaultHeight = CGFloat(500)
    let defaultMargin = CGFloat(10)
    let defaultConnectorWidth = 3.0

    var maxY: CGFloat { get { return boxes.map { $0.rect.maxY }.max() ?? defaultHeight }}
    var maxX: CGFloat { get { return boxes.map { $0.rect.maxX }.max() ?? defaultWidth }}
    var height: CGFloat { get { return maxY < (defaultHeight + defaultMargin) ? defaultHeight : maxY + defaultMargin }}
    var width: CGFloat { get { return maxX < (defaultWidth + defaultMargin) ? defaultWidth : maxX + defaultMargin} }

    var activeConnectionPath: NSBezierPath? {
        get {
            if !isConnecting { return nil }
            let p = NSBezierPath()
            p.move(to: connectStartPoint)
            p.line(to: connectEndPoint)
            p.lineWidth = CGFloat(defaultConnectorWidth)
            return p
        }
    }

    struct RenderNode {
        let isSelected: Bool
        let kind: Shape
        let path: NSBezierPath
    }

    var renders: [RenderNode] {
        get {
            let bs = boxes.map { RenderNode(isSelected: $0 === selectedObject, kind: .box, path: $0.path)}
            let cs = connectors.map { RenderNode(isSelected: $0 === selectedObject, kind: .connector, path: $0.path)}
            return cs + bs.reversed()
        }
    }

    private var selectedObject: Node?

    private var isDragging = false
    private var offsetX: CGFloat = .zero
    private var offsetY: CGFloat = .zero

    private var isConnecting = false
    private var target: Node?
    private var connectEndPoint = NSPoint(x: 0, y: 0)
    private var connectStartPoint = NSPoint(x: 0, y: 0)

    init() {
    }

    func clear() {
        boxes.removeAll()
        connectors.removeAll()
    }

    func add(origin: NSPoint) {
        let box = Box(origin: origin)
        boxes.insert(box, at: 0)
        selectedObject = box
    }

    func connect(fromBox: Box, toBox: Box) {
        connectors.insert(Connector(fromBox: fromBox, toBox: toBox, lineWidth: defaultConnectorWidth))
    }

    func remove() {
        switch selectedObject {
        case let node as Box:
            boxes.removeAll { return $0 == node }
            connectors = connectors.filter { $0.fromBox != node && $0.toBox != node }
        case let node as Connector:
            connectors = connectors.filter { $0.id != node.id }
        default:
            break
        }
        selectedObject = nil
    }

    func moveUp() {
        switch selectedObject {
        case let node as Box:
            guard let index = boxes.firstIndex(where: { $0 === node }), index != 0 else { return }
            boxes.insert(boxes.remove(at: index), at: index - 1)
        default:
            return
        }
    }

    func moveDown() {
        switch selectedObject {
        case let node as Box:
            guard let index = boxes.firstIndex(where: { $0 === node }), index != (boxes.count - 1) else { return }
            boxes.insert(boxes.remove(at: index), at: index + 1)
        default:
            return
        }
    }

    func select(objectAt point: NSPoint) -> Bool {
        for box in boxes {
            if box.contains(point) {
                selectedObject = box
                offsetX = point.x - box.rect.minX
                offsetY = point.y - box.rect.minY
                isDragging = true
                return true
            }
        }

        for conn in connectors {
            if conn.contains(point) {
                selectedObject = conn
                return true
            }
        }
        return false
    }

    func moveSelectedObject(to point: NSPoint) -> Bool {
        if !isDragging { return false }
        guard let box = selectedObject as? Box else { return false }
        let newOrigin = NSMakePoint(point.x - offsetX, point.y - offsetY)
        box.moveTo(newOrigin)
        return true
    }

    func stopMoving() {
        isDragging = false
    }

    func startConnecting(forBoxAt point: NSPoint) -> Bool {
        for box in boxes {
            if box.contains(point) {
                selectedObject = box
                isConnecting = true
                let x = box.rect.maxX - (box.rect.width / 2)
                let y = box.rect.maxY - (box.rect.height / 2)
                connectStartPoint = NSMakePoint(x,y)
                connectEndPoint = point
                return true
            }
        }
        return false
    }

    func stopConnecting(at point: NSPoint) -> Bool {
        isConnecting = false
        if let target = target as? Box,
            let selectedBox = selectedObject as? Box,
            target != selectedBox {
            connect(fromBox: selectedBox, toBox: target)
        }
        target = nil
        return true
    }

    func extendConnection(to point: NSPoint) -> Bool {
        if !isConnecting {
            return false
        }

        connectEndPoint = point
        target = boxes.first { $0.contains(point) }
        return true
    }
}
