//
//  ARView.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//

import SwiftUI
import ARKit

struct ARView: UIViewRepresentable {
    let arView = ARSCNView()

    func makeUIView(context: Context) -> ARSCNView {
        arView.session.run(ARWorldTrackingConfiguration())
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: ()) {
        uiView.session.pause()
    }
}
