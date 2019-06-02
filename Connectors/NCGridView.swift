//
//  NCGridView.swift
//  Connectors
//
//  Created by Keith Irwin on 6/1/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa


class Box {

    private var position: NSPoint
    private var size = NSSize(width: 100, height: 66)

    var rect: CGRect { return CGRect(origin: position, size: size) }

    init(origin: NSPoint) {
        self.position = origin
    }

    func moveTo(_ position: NSPoint) {
        self.position = position
    }

    func contains(_ point: NSPoint) -> Bool {
        return rect.contains(point)
    }
}

class NCGridView: NSView {

    private let defaultWidth = CGFloat(500)
    private let defaultHeight = CGFloat(500)
    private let defaultMargin = CGFloat(10)

    private var boxes = [
        Box(origin: NSPoint(x: 60, y: 60)),
        Box(origin: NSPoint(x: 100, y: 100))
    ]

    // MARK: - State while dragging a box

    private var selectedBox: Box?
    private var dragging = false
    private var offsetX: CGFloat = 10.0
    private var offsetY: CGFloat = 10.0

    // MARK: - Init

    init() {
        super.init(frame: NSMakeRect(0, 0, defaultWidth, defaultHeight))
        wantsLayer = true
        reset()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func reset() {
        for (index, box) in boxes.reversed().enumerated() {
            box.moveTo(NSPoint(x: 60 + (index * 20), y: 60 + (index * 20)))
        }
        resizeFrame()
        needsDisplay = true
    }

    func addNode() {
        let box = Box(origin: NSPoint(x: 60, y: 60))
        boxes.insert(box, at: 0)
        selectedBox = box
        resizeFrame()
        needsDisplay = true
    }

    func removeNode() {
        guard let selected = selectedBox else { return }
        boxes.removeAll(where: { $0 === selected })
        selectedBox = nil
        resizeFrame()
        needsDisplay = true
    }

    func moveNodeUp() {
        guard let selected = selectedBox else { return }
        guard let index = boxes.firstIndex(where: { $0 === selected }), index != 0 else { return }
        boxes.insert(boxes.remove(at: index), at: index - 1)
        needsDisplay = true
    }

    func moveNodeDown() {
        guard let selected = selectedBox else { return }
        guard let index = boxes.firstIndex(where: { $0 === selected }), index != (boxes.count - 1) else { return }
        boxes.insert(boxes.remove(at: index), at: index + 1)
        needsDisplay = true
    }

    func command(_ action: NCControlBar.Action) {
        switch action {
        case .reset:
            reset()
        case .addNode:
            addNode()
        case .removeNode:
            removeNode()
        case .moveNodeUp:
            moveNodeUp()
        case .moveNodeDown:
            moveNodeDown()
        }
    }

    // MARK: - Implementation details

    override var isFlipped: Bool { return true }

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

    private func render(_ box: Box) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(NSColor.controlBackgroundColor.cgColor)

        if let selected = selectedBox, selected === box {
            context.setStrokeColor(NSColor.controlAccentColor.cgColor)
        } else {
            context.setStrokeColor(NSColor.orange.cgColor)
        }

        let p = NSBezierPath(roundedRect: box.rect, xRadius: 4, yRadius: 4)
        p.lineWidth = 1
        p.fill()
        p.stroke()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawGrid()
        boxes.reversed().forEach { render($0) }
    }

    private func resizeFrame() {
        let maxY = boxes.map { $0.rect.maxY }.max() ?? defaultHeight
        let maxX = boxes.map { $0.rect.maxX }.max() ?? defaultWidth
        let height = maxY < (defaultHeight + defaultMargin) ? defaultHeight : maxY + defaultMargin
        let width = maxX < (defaultWidth + defaultMargin) ? defaultWidth : maxX + defaultMargin
        setFrameSize(NSMakeSize(width, height))
    }

    // MARK: - Actions (NSResponder)

    override func mouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        for box in boxes {
            if box.contains(place) {
                selectedBox = box
                offsetX = place.x - box.rect.minX
                offsetY = place.y - box.rect.minY
                dragging = true
                needsDisplay = true
                break
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        dragging = false
    }

    override func mouseDragged(with event: NSEvent) {
        if !dragging { return }
        guard let box = selectedBox else { return }
        let place = convert(event.locationInWindow, from: nil)
        let newOrigin = NSMakePoint(place.x - offsetX, place.y - offsetY)
        box.moveTo(newOrigin)
        resizeFrame()
        render(box)
        needsDisplay = true
    }
}


