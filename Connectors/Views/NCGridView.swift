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

    private var state: State

    // MARK: - State while dragging a thing?

    private var selectedObject: Node?

    private var dragging = false
    private var offsetX: CGFloat = 10.0
    private var offsetY: CGFloat = 10.0


    // MARK: - State while connecting

    private var connecting = false
    private var target: Node?
    private var connectEndPoint = NSPoint(x: 0, y: 0)
    private var connectStartPoint = NSPoint(x: 0, y: 0)

    // MARK: - Init

    init(state: State = State()) {
        self.state = state
        super.init(frame: NSMakeRect(0, 0, state.defaultWidth, state.defaultHeight))
        wantsLayer = true
        state.clear()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isFlipped: Bool { return true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        resizeToFit(state)
        drawGrid()
        drawConnections(state)
        drawBoxes(state)
        drawConnector(state)
    }

    // MARK: - Public

    func command(_ action: NCGridView.Action) {
        switch action {

        case .reset:
            state.clear()

        case .add:
            selectedObject = state.add(origin: NSPoint(x: 60, y: 60))

        case .remove:
            state.remove(selectedObject)
            selectedObject = nil

        case .up:
            state.moveUp(selectedObject)

        case .down:
            state.moveDown(selectedObject)
        }
        needsDisplay = true
    }

    // MARK: - Implementation details

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

    private func drawBoxes(_ state: State) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(NSColor.controlBackgroundColor.cgColor)

        state.boxes.reversed().forEach { box in
            if let selected = selectedObject as? Box, selected === box {
                context.setStrokeColor(NSColor.controlAccentColor.cgColor)
            } else if let target = target as? Box, target === box {
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

    private func drawConnector(_ state: State) {
        if !connecting {
            return
        }
        NSGraphicsContext.current?.cgContext.setStrokeColor(NSColor.controlAccentColor.cgColor)
        let p = NSBezierPath()
        p.move(to: connectStartPoint)
        p.line(to: connectEndPoint)
        p.lineWidth = CGFloat(state.defaultConnectorWidth)
        p.stroke()
    }

    private func drawConnections(_ state: State) {
        let context = NSGraphicsContext.current?.cgContext
        for connector in state.connectors {
            if let selection = selectedObject as? Connector, selection == connector {
                context?.setStrokeColor(NSColor.systemRed.cgColor)
            } else {
                context?.setStrokeColor(NSColor.systemGray.cgColor)
            }
            let path = connector.path
            path.stroke()
        }
    }

    private func resizeToFit(_ state: State) {
        let maxY = state.maxY
        let maxX = state.maxX
        let height = maxY < (state.defaultHeight + state.defaultMargin) ? state.defaultHeight : maxY + state.defaultMargin
        let width = maxX < (state.defaultWidth + state.defaultMargin) ? state.defaultWidth : maxX + state.defaultMargin
        setFrameSize(NSMakeSize(width, height))
    }

    // MARK: - Connect node actions

    override func rightMouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        for box in state.boxes {
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
            target = state.boxes.first { $0.contains(place) }
            needsDisplay = true
        }
    }

    override func rightMouseUp(with event: NSEvent) {
        connecting = false
        if let target = target as? Box,
            let selectedBox = selectedObject as? Box,
            target != selectedBox {
            state.connect(fromBox: selectedBox, toBox: target)
        }
        target = nil
        needsDisplay = true
    }

    // MARK: - Move/Select node actions

    override func mouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        for box in state.boxes {
            if box.contains(place) {
                selectedObject = box
                offsetX = place.x - box.rect.minX
                offsetY = place.y - box.rect.minY
                dragging = true
                needsDisplay = true
                return
            }
        }

        for conn in state.connectors {
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


