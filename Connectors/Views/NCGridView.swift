//
//  NCGridView.swift
//  Connectors
//
//  Created by Keith Irwin on 6/1/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class NCGridView: NSView {

    private var state: State

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
        resizeToFit()
        drawGrid()
        drawConnections()
        drawBoxes()
        drawConnector()
    }

    // MARK: - Public

    func render(state: State) {
        self.state = state
        needsDisplay = true
    }

    // MARK: - Implementation details

    private func drawGrid() {
        let gridSize = state.defaultGridSize

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

        state.boxes.reversed().forEach { box in
            if let selected = state.selectedObject as? Box, selected === box {
                context.setStrokeColor(NSColor.controlAccentColor.cgColor)
            } else if let target = state.target as? Box, target === box {
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
        if !state.isConnecting {
            return
        }
        NSGraphicsContext.current?.cgContext.setStrokeColor(NSColor.controlAccentColor.cgColor)
        let p = NSBezierPath()
        p.move(to: state.connectStartPoint)
        p.line(to: state.connectEndPoint)
        p.lineWidth = CGFloat(state.defaultConnectorWidth)
        p.stroke()
    }

    private func drawConnections() {
        let context = NSGraphicsContext.current?.cgContext
        for connector in state.connectors {
            if let selection = state.selectedObject as? Connector, selection == connector {
                context?.setStrokeColor(NSColor.systemRed.cgColor)
            } else {
                context?.setStrokeColor(NSColor.systemGray.cgColor)
            }
            let path = connector.path
            path.stroke()
        }
    }

    private func resizeToFit() {
        setFrameSize(NSMakeSize(state.width, state.height))
    }

    // MARK: - Connect node actions

    override func rightMouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        for box in state.boxes {
            if box.contains(place) {
                state.selectedObject = box
                state.isConnecting = true
                let x = box.rect.maxX - (box.rect.width / 2)
                let y = box.rect.maxY - (box.rect.height / 2)
                state.connectStartPoint = NSMakePoint(x,y)
                state.connectEndPoint = place
                needsDisplay = true
                break
            }
        }
    }

    override func rightMouseDragged(with event: NSEvent) {
        if state.isConnecting {
            let place = convert(event.locationInWindow, from: nil)
            state.connectEndPoint = place
            state.target = state.boxes.first { $0.contains(place) }
            needsDisplay = true
        }
    }

    override func rightMouseUp(with event: NSEvent) {
        state.isConnecting = false
        if let target = state.target as? Box,
            let selectedBox = state.selectedObject as? Box,
            target != selectedBox {
            state.connect(fromBox: selectedBox, toBox: target)
        }
        state.target = nil
        needsDisplay = true
    }

    // MARK: - Move/Select node actions

    override func mouseDown(with event: NSEvent) {
        needsDisplay = state.select(at: event.place(self))
    }

    override func mouseUp(with event: NSEvent) {
        state.isDragging = false
    }

    override func mouseDragged(with event: NSEvent) {
        needsDisplay = state.moveSelection(to: event.place(self))
    }
}


extension NSEvent {
    func place(_ view: NSView) -> NSPoint {
        return view.convert(locationInWindow, from: nil)
    }
}
