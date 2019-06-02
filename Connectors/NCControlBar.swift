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
        case removeNode
        case moveNodeDown
        case moveNodeUp
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

    private lazy var delButton: NSButton = {
        let b = NSButton()
        b.bezelStyle = .roundRect
        b.isBordered = false
        b.image = NSImage(named: NSImage.removeTemplateName)
        b.action = #selector(buttonClicked(_:))
        b.target = self
        b.toolTip = "Delete selected node"
        return b
    }()

    private var moveUp = NSButton()
    private var moveDown = NSButton()

    var action: ((Action) -> Void)?

    init() {


        super.init(frame: .zero)
        setButton(moveUp, named: NSImage.touchBarGoUpTemplateName, tooltip: "Move node up.")
        setButton(moveDown, named: NSImage.touchBarGoDownTemplateName, tooltip: "Move node down.")

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
            action?(.addNode)
        case delButton:
            action?(.removeNode)
        case moveDown:
            action?(.moveNodeDown)
        case moveUp:
            action?(.moveNodeUp)
        default:
            break
        }
    }
}
