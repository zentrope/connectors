//
//  ViewController.swift
//  Connectors
//
//  Created by Keith Irwin on 5/31/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class NCGridView: NSView {

    private let defaultWidth = CGFloat(500)
    private let defaultHeight = CGFloat(500)
    private let defaultMargin = CGFloat(10)

    private var box: CGRect = .zero

    init() {
        super.init(frame: NSMakeRect(0, 0, defaultWidth, defaultHeight))
        wantsLayer = true
        reset()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func reset() {
        box = CGRect(x: 60, y: 60, width: 100, height: 66)
        setFrameSize(NSMakeSize(defaultWidth, defaultHeight))
        needsDisplay = true
    }

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

    private func render(_ box: CGRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setFillColor(NSColor.controlBackgroundColor.cgColor)
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

    private func resizeFrame(box: CGRect) {
        let height = box.maxY < (defaultHeight + defaultMargin) ? bounds.height : box.maxY + defaultMargin
        let width = box.maxX < (defaultWidth + defaultMargin) ? defaultWidth : box.maxX + defaultMargin
        setFrameSize(NSMakeSize(width, height))
    }

    // MARK: - Actions (NSResponder)

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
        resizeFrame(box: box)
        render(box)
        needsDisplay = true
    }
}


class NCControlBar: NSView {

    enum Action {
        case reset
    }

    private var resetButton = NSButton()

    var action: ((Action) -> Void)?

    init() {
        super.init(frame: .zero)

        addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.bezelStyle = .roundRect
        resetButton.isBordered = false        
        resetButton.image = NSImage(named: NSImage.refreshTemplateName)
        resetButton.action = #selector(resetButtonClicked(_:))
        resetButton.target = self
        resetButton.toolTip = "Reset everything and start over"
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            resetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            resetButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ])

        wantsLayer = true
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }

    @objc func resetButtonClicked(_ sender: NSButton) {
        action?(.reset)
    }
}

class ViewController: NSViewController {

    var scrollView = NSScrollView(frame: .zero)
    var backgroundView = NCGridView()
    var controlBar = NCControlBar()

    override func loadView() {
        let view = NSView()

        scrollView.documentView = backgroundView
        scrollView.contentView.setValue(true, forKey: "flipped")
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true

        view.addSubview(controlBar)
        view.addSubview(scrollView)

        controlBar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 500),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 500),
            controlBar.topAnchor.constraint(equalTo: view.topAnchor),
            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: controlBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        controlBar.action = controlBarAction
    }

    private func controlBarAction(_ action: NCControlBar.Action) {
        switch action {
        case .reset: backgroundView.reset()
        }
    }
}
