//
//  ARSessionWrapper.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//

import Foundation
import ARKit

class ARSessionWrapper: ObservableObject {
    @Published var arView = ARSCNView()
    @Published var timer: Timer?

    init() {
        arView.session.run(ARWorldTrackingConfiguration())
    }

    deinit {
        arView.session.pause()
        timer?.invalidate()
        timer = nil
    }
}
