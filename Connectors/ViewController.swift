//
//  ViewController.swift
//  Connectors
//
//  Created by Keith Irwin on 5/31/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var canvasView = NCCanvasView()
    var controlBar = NCControlBar()

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

    private func controlBarAction(_ action: NCControlBar.Action) {
        switch action {
        case .reset: canvasView.reset()
        }
    }
}
