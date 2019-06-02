//
//  NCControlBar.swift
//  Connectors
//
//  Created by Keith Irwin on 6/1/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class NCControlBar: NSView {

    private var resetButton = NSButton()
    private var addButton = NSButton()
    private var delButton = NSButton()
    private var moveUp = NSButton()
    private var moveDown = NSButton()

    var action: ((NCGridView.Action) -> Void)?

    init() {
        super.init(frame: .zero)
        setButton(resetButton, named: NSImage.refreshTemplateName, tooltip: "Cascade nodes")
        setButton(addButton, named: NSImage.addTemplateName, tooltip: "Add a new node")
        setButton(delButton, named: NSImage.removeTemplateName, tooltip: "Delete selected node")
        setButton(moveUp, named: NSImage.touchBarGoUpTemplateName, tooltip: "Move node up")
        setButton(moveDown, named: NSImage.touchBarGoDownTemplateName, tooltip: "Move node down")

        addSubview(resetButton)
        addSubview(addButton)
        addSubview(delButton)
        addSubview(moveUp)
        addSubview(moveDown)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        delButton.translatesAutoresizingMaskIntoConstraints = false
        moveUp.translatesAutoresizingMaskIntoConstraints = false
        moveDown.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            resetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            resetButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            delButton.trailingAnchor.constraint(equalTo: resetButton.leadingAnchor, constant: -20),
            delButton.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: delButton.leadingAnchor, constant: -10),
            addButton.centerYAnchor.constraint(equalTo: delButton.centerYAnchor),
            moveDown.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -20),
            moveDown.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor),
            moveUp.trailingAnchor.constraint(equalTo: moveDown.leadingAnchor, constant: -10),
            moveUp.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor)
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

    private func setButton(_ b: NSButton, named: String, tooltip: String) {
        b.bezelStyle = .roundRect
        b.isBordered = false
        b.image = NSImage(named: named)
        b.action = #selector(buttonClicked(_:))
        b.target = self
        b.toolTip = tooltip
    }

    @objc func buttonClicked(_ sender: NSButton) {
        switch sender {
        case resetButton:
            action?(.reset)
        case addButton:
            action?(.add)
        case delButton:
            action?(.remove)
        case moveDown:
            action?(.down)
        case moveUp:
            action?(.up)
        default:
            break
        }
    }
}
