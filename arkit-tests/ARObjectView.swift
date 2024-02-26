//
//  ARObjectView.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//

import SwiftUI

struct ARObjectView: View {
    
    @State private var isObjectPlaced = false
    @State private var scale: Float = 10.0

    @StateObject private var sessionWrapper = ARSessionWrapper()

    var body: some View {
        VStack {
            ARViewContainer(
                isObjectPlaced: $isObjectPlaced,
                scale: $scale,
                sessionWrapper: sessionWrapper
            )
                .edgesIgnoringSafeArea(.all)

            Slider(
                value: $scale,
                in: 0...100
            )
            .disabled(!isObjectPlaced)
            .accentColor(isObjectPlaced ? .green : .gray)
            .id(isObjectPlaced)

            if isObjectPlaced {

                Button("Delete Object") {
                    self.deleteObject()
                }.padding()
            } else {
                Button("Place Object") {
                    self.placeObject()
                }.padding()
            }
            
            
        }
    }
    
    func placeObject() {
        self.isObjectPlaced = true
    }
    
    func deleteObject() {
        self.isObjectPlaced = false
    }
}

struct ARObjectView_Previews: PreviewProvider {
    static var previews: some View {
        ARObjectView()
    }
}
