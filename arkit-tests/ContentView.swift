//
//  ContentView.swift
//  arkit-tests
//
//  Created by Andrii Vivcharenko on 26.02.2024.
//


import SwiftUI
import ARKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: ARObjectView()) {
                Text("Place Object View")
            }
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
