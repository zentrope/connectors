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
        case addNode
    }

    private lazy var resetButton : NSButton = {
        let b = NSButton()
        b.bezelStyle = .roundRect
        b.isBordered = false
        b.image = NSImage(named: NSImage.refreshTemplateName)
        b.action = #selector(buttonClicked(_:))
        b.target = self
        b.toolTip = "Reset everything and start over"
        return b
    }()

    private lazy var addButton: NSButton = {
        let b = NSButton()
        b.bezelStyle = .roundRect
        b.isBordered = false
        b.image = NSImage(named: NSImage.addTemplateName)
        b.action = #selector(buttonClicked(_:))
        b.target = self
        b.toolTip = "Add a new node"
        return b
    }()

    var action: ((Action) -> Void)?

    init() {
        super.init(frame: .zero)

        addSubview(resetButton)
        addSubview(addButton)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            resetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            resetButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            addButton.trailingAnchor.constraint(equalTo: resetButton.leadingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor)
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

    @objc func buttonClicked(_ sender: NSButton) {
        switch sender {
        case resetButton:
            action?(.reset)
        case addButton:
            action?(.addNode)
        default:
            break
        }
    }
}
