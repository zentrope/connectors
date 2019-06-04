//
//  NCGridView.swift
//  Connectors
//
//  Created by Keith Irwin on 6/1/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa


class NCGridView: NSView {

    enum Action {
        case reset
        case add
        case remove
        case down
        case up
    }

    private let defaultWidth = CGFloat(500)
    private let defaultHeight = CGFloat(500)
    private let defaultMargin = CGFloat(10)
    private let defaultConnectorWidth = 2.0

    // First position is top of the view hierarchy

    private var boxes = [
        Box(origin: NSPoint(x: 60, y: 60)),
        Box(origin: NSPoint(x: 100, y: 100))
    ]

    private var connectors = Set<Connector>()

    // TODO: boxes and connectors should be a Set<Node>.

    // MARK: - State while dragging a thing?

    private var selectedObject: Node?

    private var dragging = false
    private var offsetX: CGFloat = 10.0
    private var offsetY: CGFloat = 10.0


    // MARK: - State while connecting

    private var connecting = false
    private var targetBox: Box?
    private var connectEndPoint = NSPoint(x: 0, y: 0)
    private var connectStartPoint = NSPoint(x: 0, y: 0)

    // MARK: - Init

    init() {
        super.init(frame: NSMakeRect(0, 0, defaultWidth, defaultHeight))
        wantsLayer = true
        reset()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isFlipped: Bool { return true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        resizeToFit()
        drawGrid()
        drawConnections()
        drawBoxes()
        drawConnector()
    }

    // MARK: - Public

    // TODO: Separate the state management from the render stuff

    func command(_ action: NCGridView.Action) {
        switch action {
        case .reset:
            reset()
        case .add:
            addNode()
        case .remove:
            removeNode()
        case .up:
            moveNodeUp()
        case .down:
            moveNodeDown()
        }
        needsDisplay = true
    }

    // MARK: - Implementation details

    private func reset() {
        for (index, box) in boxes.reversed().enumerated() {
            box.moveTo(NSPoint(x: 60 + (index * 20), y: 60 + (index * 20)))
        }
    }

    private func addNode() {
        let box = Box(origin: NSPoint(x: 60, y: 60))
        boxes.insert(box, at: 0)
        selectedObject = box
    }

    private func removeNode() {
        guard let selected = selectedObject as? Box else { return }
        boxes.removeAll { $0 === selected }
        connectors = connectors.filter { $0.fromBox !== selected && $0.toBox !== selected }
        selectedObject = nil
    }

    private func moveNodeUp() {
        guard let selected = selectedObject as? Box else { return }
        guard let index = boxes.firstIndex(where: { $0 === selected }), index != 0 else { return }
        boxes.insert(boxes.remove(at: index), at: index - 1)
    }

    private func moveNodeDown() {
        guard let selected = selectedObject as? Box else { return }
        guard let index = boxes.firstIndex(where: { $0 === selected }), index != (boxes.count - 1) else { return }
        boxes.insert(boxes.remove(at: index), at: index + 1)
    }

    private func drawGrid() {
        let gridSize = 20

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.setStrokeColor(NSColor.controlAccentColor.cgColor)
        context.setLineWidth(0.2)

        context.beginPath()
        context.addRect(bounds)

        for row in Int(bounds.minY)...Int(bounds.maxY) {
            if row % gridSize == 0 {
                context.addLines(between: [CGPoint(x: bounds.minX, y: CGFloat(row)), CGPoint(x: bounds.maxX, y: CGFloat(row))])
            }
        }

        for col in Int(bounds.minX)...Int(bounds.maxX) {
            if col % gridSize == 0 {
                context.addLines(between: [CGPoint(x: CGFloat(col), y: bounds.minY), CGPoint(x: CGFloat(col), y: bounds.maxY)])
            }
        }

        context.strokePath()
    }

    private func drawBoxes() {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(NSColor.controlBackgroundColor.cgColor)

        boxes.reversed().forEach { box in
            if let selected = selectedObject as? Box, selected === box {
                context.setStrokeColor(NSColor.controlAccentColor.cgColor)
            } else if let target = targetBox, target === box {
                context.setStrokeColor(NSColor.controlAccentColor.cgColor)
            } else {
                context.setStrokeColor(NSColor.orange.cgColor)
            }

            let p = NSBezierPath(roundedRect: box.rect, xRadius: 4, yRadius: 4)
            p.lineWidth = 1
            p.fill()
            p.stroke()
        }
    }

    private func drawConnector() {
        if !connecting {
            return
        }
        NSGraphicsContext.current?.cgContext.setStrokeColor(NSColor.controlAccentColor.cgColor)
        let p = NSBezierPath()
        p.move(to: connectStartPoint)
        p.line(to: connectEndPoint)
        p.lineWidth = CGFloat(defaultConnectorWidth)
        p.stroke()
    }

    private func drawConnections() {
        let context = NSGraphicsContext.current?.cgContext //.setStrokeColor(NSColor.systemGray.cgColor)
        for connector in connectors {
            if let selection = selectedObject as? Connector, selection == connector {
                context?.setFillColor(NSColor.systemRed.cgColor)
            } else {
                context?.setFillColor(NSColor.systemGray.cgColor)
            }
            let path = connector.path
            path.lineWidth = 0
            path.fill()
        }
    }

    private func resizeToFit() {
        let maxY = boxes.map { $0.rect.maxY }.max() ?? defaultHeight
        let maxX = boxes.map { $0.rect.maxX }.max() ?? defaultWidth
        let height = maxY < (defaultHeight + defaultMargin) ? defaultHeight : maxY + defaultMargin
        let width = maxX < (defaultWidth + defaultMargin) ? defaultWidth : maxX + defaultMargin
        setFrameSize(NSMakeSize(width, height))
    }

    // MARK: - Connect node actions

    override func rightMouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        for box in boxes {
            if box.contains(place) {
                selectedObject = box
                connecting = true
                let x = box.rect.maxX - (box.rect.width / 2)
                let y = box.rect.maxY - (box.rect.height / 2)
                connectStartPoint = NSMakePoint(x,y)
                connectEndPoint = place
                needsDisplay = true
                break
            }
        }
    }

    override func rightMouseDragged(with event: NSEvent) {
        if connecting {
            let place = convert(event.locationInWindow, from: nil)
            connectEndPoint = place
            targetBox = boxes.first { $0.contains(place) }
            needsDisplay = true
        }
    }

    override func rightMouseUp(with event: NSEvent) {
        connecting = false
        if let targetBox = targetBox,
            let selectedBox = selectedObject as? Box,
            targetBox != selectedBox {
            let connector = Connector(fromBox: selectedBox, toBox: targetBox, lineWidth: defaultConnectorWidth)
            connectors.insert(connector)
        }
        targetBox = nil
        needsDisplay = true
    }

    // MARK: - Move/Select node actions

    override func mouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        for box in boxes {
            if box.contains(place) {
                selectedObject = box
                offsetX = place.x - box.rect.minX
                offsetY = place.y - box.rect.minY
                dragging = true
                needsDisplay = true
                return
            }
        }

        for conn in connectors {
            if conn.contains(place) {
                selectedObject = conn
                needsDisplay = true
                return
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        dragging = false
    }

    override func mouseDragged(with event: NSEvent) {
        if !dragging { return }
        guard let box = selectedObject as? Box else { return }
        let place = convert(event.locationInWindow, from: nil)
        let newOrigin = NSMakePoint(place.x - offsetX, place.y - offsetY)
        box.moveTo(newOrigin)
        needsDisplay = true
    }
}


