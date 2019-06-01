//
//  ViewController.swift
//  Connectors
//
//  Created by Keith Irwin on 5/31/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class BackgroundView: NSView {

    private var reset = NSButton()

    var box: CGRect = .zero

    init() {
        super.init(frame: NSMakeRect(0, 0, 600, 600))

        addSubview(reset)
        reset.title = "Reset"
        reset.bezelStyle = .texturedSquare
        reset.translatesAutoresizingMaskIntoConstraints = false
        reset.action = #selector(resetClicked(_:))
        reset.target = self
        NSLayoutConstraint.activate([
            reset.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            reset.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        wantsLayer = true

        resetClicked(reset)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func resetClicked(_ sender: NSButton) {
        // Do this because not accounting for scrolling off screen on window size change
        box = CGRect(x: 20, y: bounds.maxY - 20 - 66, width: 100, height: 66)
        needsDisplay = true
    }

    private func drawGrid() {
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setStrokeColor(NSColor.gray.cgColor)
        context.setLineWidth(0.2)

        for row in Int(bounds.minY)...Int(bounds.maxY) {
            if row % 20 == 0 {
                context.beginPath()
                context.move(to: CGPoint(x: bounds.minX, y: CGFloat(row)))
                context.addLine(to: CGPoint(x: bounds.maxX, y: CGFloat(row)))
                context.strokePath()
            }
        }

        for col in Int(bounds.minX)...Int(bounds.maxX) {
            if col % 20 == 0 {
                context.beginPath()
                context.move(to: CGPoint(x: CGFloat(col), y: bounds.minY))
                context.addLine(to: CGPoint(x: CGFloat(col), y: bounds.maxY))
                context.strokePath()
            }
        }

        needsDisplay = true
    }

    private func render(_ box: CGRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(NSColor.white.cgColor)
        context.setStrokeColor(NSColor.orange.cgColor)
        let p = NSBezierPath(roundedRect: box, xRadius: 10, yRadius: 10)
        p.lineWidth = 2
        p.fill()
        p.stroke()
    }

    var dragging = false
    var offsetX: CGFloat = 10.0
    var offsetY: CGFloat = 10.0

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawGrid()
        render(box)
    }

    override func mouseDown(with event: NSEvent) {
        let place = convert(event.locationInWindow, from: nil)
        if box.contains(place) {
            offsetX = place.x - box.minX
            offsetY = place.y - box.minY
            dragging = true
        }
    }

    override func mouseUp(with event: NSEvent) {
        dragging = false
    }

    override func mouseDragged(with event: NSEvent) {
        if !dragging { return }
        let place = convert(event.locationInWindow, from: nil)
        box = CGRect(x: place.x - offsetX, y: place.y - offsetY, width: box.width, height: box.height)
        render(box)
        needsDisplay = true
    }
}

class ViewController: NSViewController {

    override func loadView() {
        self.view = BackgroundView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

