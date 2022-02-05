//
//  NetworkHandler.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import SwiftUI

struct NetworkHandler<Content: View>: View {
    
    @ViewBuilder var content: (_ isOnline: Binding<Bool>) -> Content
    @StateObject var network = NetworkObserver()
    
    var body: some View {
        content($network.isOnline.animation(.spring()))
            .environmentObject(network)
    }
}

struct NetworkHandler_Previews: PreviewProvider {
    static var previews: some View {
        NetworkHandler() { isOnline in
            Text("isOnline: \(isOnline.wrappedValue ? "true" : "false")")
        }
    }
}
