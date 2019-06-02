//
//  NCCanvasView.swift
//  Connectors
//
//  Created by Keith Irwin on 6/1/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class NCCanvasView: NSView {

    private var gridView = NCGridView()
    private var scrollView = NSScrollView(frame: .zero)

    init() {
        super.init(frame: .zero)
        scrollView.documentView = gridView
        scrollView.contentView.setValue(true, forKey: "flipped")
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    func reset() {
        print("reset")
        gridView.reset()
    }
}
