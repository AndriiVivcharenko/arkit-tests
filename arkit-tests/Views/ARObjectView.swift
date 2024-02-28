//
//  ARObjectView.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//

import SwiftUI
import OpenAI

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

            HStack {
                if isObjectPlaced {

                    Button("Delete Object") {
                        self.deleteObject()
                    }.padding().disabled(true)
                } else {
                    Button("Place Object") {
                        self.placeObject()
                    }.padding().disabled(true)
                }

                Button("Request GPT4V") {
                    sessionWrapper.requestGpt4V() { response in
                        print(response)
                    }
                }.disabled(true)
            }
            
            
        }.onDisappear {
            sessionWrapper.deinitialize()
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
