//
//  ARViewContainer.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//

import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var isObjectPlaced: Bool
    @Binding var scale: Float
    @ObservedObject var sessionWrapper: ARSessionWrapper

    static let indicatorNodeName = "indicatorNode"
    @State private var updateTimer: Timer?

    func makeUIView(context: Context) -> ARSCNView {
        sessionWrapper.timer = updateIndicatorPosition(uiView: sessionWrapper.arView)
        return sessionWrapper.arView
    }

    func getScale() -> SCNVector3 {
        let scaleRatio = scale / 100000
        return SCNVector3(scaleRatio, scaleRatio, scaleRatio)
    }

    func getCurrentObject(uiView: ARSCNView) -> SCNNode? {
        let childrenNodes = uiView.scene.rootNode.childNodes
        for children in childrenNodes {
            if children.name != ARViewContainer.indicatorNodeName {
                return children
            }
        }
        return nil
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if isObjectPlaced {
            if let currentObject = getCurrentObject(uiView: uiView) {
                currentObject.scale = self.getScale()
                print(self.getScale())
            } else {
                if let frame = uiView.session.currentFrame {
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.5 // Adjust the distance in front of the camera

                    let transform = frame.camera.transform * translation

                    var position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

                    if let hitTestPosition = hitTest(uiView: uiView) {
                        position = hitTestPosition
                    }

                    if let modelUrl = Bundle.main.url(forResource: "Chair", withExtension: "usdz") {
                        if let modelScene = try? SCNScene(url: modelUrl, options: nil) {
                            if let modelNode = modelScene.rootNode.childNode(withName: "Sketchfab_model", recursively: true) {
                                modelNode.scale = self.getScale()
                                modelNode.position = position

                                uiView.scene.rootNode.addChildNode(modelNode)

                            }
                        }
                    }
                }

            }
        } else {
            if let currentObject = getCurrentObject(uiView: uiView) {
                currentObject.removeFromParentNode()
            }
        }
    }

    private func updateIndicatorPosition(uiView: ARSCNView) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
            if let frame = uiView.session.currentFrame {
                let cameraTransform = frame.camera.transform

                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.5

                translation = cameraTransform * translation
                var position = SCNVector3(
                    translation.columns.3.x,
                    translation.columns.3.y,
                    translation.columns.3.z
                )

                if let hitTestResult = hitTest(uiView: uiView) {
                    position = hitTestResult
                }

                let indicatorNode = createIndicatorNode()
                indicatorNode.position = position

                for children in uiView.scene.rootNode.childNodes {
                    if children.name == ARViewContainer.indicatorNodeName {
                        children.removeFromParentNode()
                    }
                }

                if !isObjectPlaced {
                    uiView.scene.rootNode.addChildNode(indicatorNode)
                }

            }
        }
    }

    private func createIndicatorNode() -> SCNNode {
        // Create your indicator node here
        // Replace this with your own indicator model
        let sphere = SCNSphere(radius: 0.05)
        let indicatorNode = SCNNode(geometry: sphere)
        indicatorNode.name = ARViewContainer.indicatorNodeName // Name the node for removal

        // You can customize the appearance of the indicator
        indicatorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)

        return indicatorNode
    }

    private func hitTest(uiView: ARSCNView) -> SCNVector3? {
        let hitTestResult = uiView.hitTest(uiView.center, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if let hitResult = hitTestResult.first {
            return SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y,
                hitResult.worldTransform.columns.3.z
            )
        }
        return nil
    }

    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }



    static func dismantleUIView(_ uiView: ARSCNView, coordinator: ())  {
        uiView.session.pause()
    }
    
    
}
