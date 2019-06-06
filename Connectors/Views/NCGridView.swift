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
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isFlipped: Bool { return true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let ctx = NSGraphicsContext.current?.cgContext {
            resizeToFit()
            drawGrid(ctx)
            drawNodes(ctx)
            drawConnector(ctx)
        }
    }

    // MARK: - Public

    func render(state: State) {
        self.state = state
        needsDisplay = true
    }

    // MARK: - Drawing

    private func drawGrid(_ ctx: CGContext) {
        let gridSize = state.defaultGridSize

        ctx.accentStroke()
        ctx.setLineWidth(0.2)

        ctx.beginPath()
        ctx.addRect(bounds)

        for row in Int(bounds.minY)...Int(bounds.maxY) {
            if row % gridSize == 0 {
                ctx.addLines(between: [CGPoint(x: bounds.minX, y: CGFloat(row)), CGPoint(x: bounds.maxX, y: CGFloat(row))])
            }
        }

        for col in Int(bounds.minX)...Int(bounds.maxX) {
            if col % gridSize == 0 {
                ctx.addLines(between: [CGPoint(x: CGFloat(col), y: bounds.minY), CGPoint(x: CGFloat(col), y: bounds.maxY)])
            }
        }

        ctx.strokePath()
    }

    private func drawNodes(_ ctx: CGContext) {
        ctx.backgroundFill()

        state.renders.forEach { render in
            if render.isSelected {
                ctx.accentStroke()
            } else if render.kind == .connector {
                ctx.grayStroke()
            } else {
                ctx.orangeStroke()
            }
            render.path.fill()
            render.path.stroke()
        }
    }

    private func drawConnector(_ ctx: CGContext) {
        ctx.accentStroke()
        state.activeConnectionPath?.stroke()
    }

    private func resizeToFit() {
        setFrameSize(NSMakeSize(state.width, state.height))
    }

    // MARK: - Mousing

    override func rightMouseDown(with event: NSEvent) {
        needsDisplay = state.startConnecting(forBoxAt: event.place(self))
    }

    override func rightMouseDragged(with event: NSEvent) {
        needsDisplay = state.extendConnection(to: event.place(self))
    }

    override func rightMouseUp(with event: NSEvent) {
        needsDisplay = state.stopConnecting(at: event.place(self))
    }

    override func mouseDown(with event: NSEvent) {
        needsDisplay = state.select(objectAt: event.place(self))
    }

    override func mouseUp(with event: NSEvent) {
        state.stopMoving()
    }

    override func mouseDragged(with event: NSEvent) {
        needsDisplay = state.moveSelectedObject(to: event.place(self))
    }
}
