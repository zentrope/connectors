//
//  State.swift
//  Connectors
//
//  Created by Keith Irwin on 6/4/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Foundation

class State {

    private(set) var boxes = [Box]()
    private(set) var connectors = Set<Connector>()

    let defaultWidth = CGFloat(500)
    let defaultHeight = CGFloat(500)
    let defaultMargin = CGFloat(10)
    let defaultConnectorWidth = 2.0

    var maxY: CGFloat { get { return boxes.map { $0.rect.maxY }.max() ?? defaultHeight }}
    var maxX: CGFloat { get { return boxes.map { $0.rect.maxX }.max() ?? defaultWidth }}

    init() {
    }

    func clear() {
        boxes.removeAll()
        connectors.removeAll()
    }

    func add(origin: NSPoint) -> Box {
        let box = Box(origin: origin)
        boxes.insert(box, at: 0)
        return box
    }

    func connect(fromBox: Box, toBox: Box) {
        connectors.insert(Connector(fromBox: fromBox, toBox: toBox, lineWidth: defaultConnectorWidth))
    }

    func remove(_ node: Node?) {
        switch node {
        case let node as Box:
            boxes.removeAll { return $0 == node }
            connectors = connectors.filter { $0.fromBox != node && $0.toBox != node }
        case let node as Connector:
            connectors = connectors.filter { $0.id != node.id }
        default:
            break
        }
    }

    func moveUp(_ node: Node?) {
        switch node {
        case let node as Box:
            guard let index = boxes.firstIndex(where: { $0 === node }), index != 0 else { return }
            boxes.insert(boxes.remove(at: index), at: index - 1)
        default:
            return
        }
    }

    func moveDown(_ node: Node?) {
        switch node {
        case let node as Box:
            guard let index = boxes.firstIndex(where: { $0 === node }), index != (boxes.count - 1) else { return }
            boxes.insert(boxes.remove(at: index), at: index + 1)
        default:
            return
        }
    }
}
