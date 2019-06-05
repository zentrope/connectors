//
//  ViewController.swift
//  Connectors
//
//  Created by Keith Irwin on 5/31/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // TODO: Put state here, then pass it in?
    
    var canvasView: NCCanvasView
    var controlBar: NCControlBar
    var state: State

    required init?(coder: NSCoder) {
        state = State()
        canvasView = NCCanvasView(state: state)
        controlBar = NCControlBar()
        super.init(coder: coder)
    }

    override func loadView() {
        let view = NSView()

        view.addSubview(controlBar)
        view.addSubview(canvasView)

        controlBar.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 500),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 500),
            controlBar.topAnchor.constraint(equalTo: view.topAnchor),
            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            canvasView.topAnchor.constraint(equalTo: controlBar.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        controlBar.action = controlBarAction
    }

    private func controlBarAction(_ action: NCGridView.Action) {
        switch action {

        case .reset:
            state.clear()

        case .add:
            state.add(origin: NSPoint(x: 60, y: 60))

        case .remove:
            state.remove()

        case .up:
            state.moveUp()

        case .down:
            state.moveDown()
        }
        canvasView.render(state: state)
    }
}
