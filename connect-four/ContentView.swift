//
//  ContentView.swift
//  connect4-swiftui
//
//  Created by Matt Pengelly on 2022-09-26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Connect 4")
            ConnectBoardView()
        }
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
