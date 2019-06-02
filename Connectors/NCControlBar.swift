//
//  NCControlBar.swift
//  Connectors
//
//  Created by Keith Irwin on 6/1/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

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
