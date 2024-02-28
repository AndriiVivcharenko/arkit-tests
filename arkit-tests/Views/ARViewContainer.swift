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

    func makeUIView(context: Context) -> ARSCNView {
        sessionWrapper.timer = runUpdateIndicatorPosition(uiView: sessionWrapper.arView)
        return sessionWrapper.arView
    }

    func getScale() -> SCNVector3 {
        let scaleRatio = scale / 100
        return SCNVector3(scaleRatio, scaleRatio, scaleRatio)
    }

    func getCurrentObject(uiView: ARSCNView) -> SCNNode? {
        let childrenNodes = uiView.scene.rooÇtNode.childNodes
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
                if  let modelNode = createModelFromResource(modelName: "Half_circle_console_table", extensionName: "usdz", rootMeshName: "Sketchfab_model") {
                    if let indicatorPosition = getCurrentObject(uiView: uiView)?.position {
                        modelNode.scale = self.getScale()
                        modelNode.position = indicatorPosition
                        uiView.scene.rootNode.addChildNode(modelNode)
                    }
                }

            }
        } else {
            if let currentObject = getCurrentObject(uiView: uiView) {
                currentObject.removeFromParentNode()
            }
        }
    }

    private func createModelFromResource(modelName: String, extensionName: String, rootMeshName: String) -> SCNNode? {
        if let modelUrl = Bundle.main.url(forResource: modelName, withExtension: extensionName) {
            if let modelScene = try? SCNScene(url: modelUrl, options: nil) {
                if let modelNode = modelScene.rootNode.childNode(withName: rootMeshName, recursively: true) {
                    return modelNode
                }
            }
        }
        return nil
    }

    private func updateInditcatorPosition(uiView: ARSCNView) -> Void {
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


            let screenWidth = Float(uiView.bounds.width)
            let screenHeight = Float(uiView.bounds.height)



            sessionWrapper.requestGpt4V() { response in

                let normalizedPosition = convertNormalizedToAbsolutePosition(
                    width: CGFloat(screenHeight),
                    height: CGFloat(screenHeight),
                    normalizedX: CGFloat(response.x),
                    normalizedY: CGFloat(response.y)
                )

                print(normalizedPosition)

                if let hitTestResult = hitTest(uiView: uiView, point: normalizedPosition) {
                    position = hitTestResult
                }

                for children in uiView.scene.rootNode.childNodes {
                    if children.name == ARViewContainer.indicatorNodeName {
                        children.removeFromParentNode()
                    }
                }

                if let indicatorNode = createIndicatorNode() {
                    indicatorNode.position = position
                    if !isObjectPlaced {
                        uiView.scene.rootNode.addChildNode(indicatorNode)
                    }
                }
            }




        }
    }

    func runUpdateIndicatorPosition(uiView: ARSCNView) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateInditcatorPosition(uiView: uiView)
        }
    }

    private func createIndicatorNode() -> SCNNode? {
        // Create your indicator node here
        // Replace this with your own indicator model
        let indicatorNode = createModelFromResource(modelName: "Circle", extensionName: "usdz", rootMeshName: "Sketchfab_model")
        if indicatorNode == nil {
            return nil
        }

        indicatorNode!.scale = SCNVector3(0.05, 0.05, 0.05)

        indicatorNode!.name = ARViewContainer.indicatorNodeName // Name the node for removal

        // You can customize the appearance of the indicator
        indicatorNode!.geometry?.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)

        return indicatorNode
    }

    private func hitTest(uiView: ARSCNView, point: CGPoint? = nil) -> SCNVector3? {
        let hitTestResult = uiView.hitTest(
            point ?? uiView.center,
           types: [
            .existingPlaneUsingExtent,
            .estimatedHorizontalPlane
           ]
        )
        if let hitResult = hitTestResult.first {
            return SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y,
                hitResult.worldTransform.columns.3.z
            )
        }
        return nil
    }

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: ())  {
        uiView.session.pause()
    }

    func convertNormalizedToAbsolutePosition(width: CGFloat, height: CGFloat, normalizedX: CGFloat, normalizedY: CGFloat) -> CGPoint {
        let absoluteX = (normalizedX + 1.0) / 2.0 * width
        let absoluteY = (1.0 - normalizedY) / 2.0 * height
        return CGPoint(x: absoluteX, y: absoluteY)
    }
}
