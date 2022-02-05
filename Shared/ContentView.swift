//
//  ContentView.swift
//  Shared
//
//  Created by Bri on 2/1/22.
//

import SwiftUI
import RealmSwift
import ErrorHandler

struct ContentView: View {
    
    @EnvironmentObject var content: ContentObserver
    
    @ObservedResults(Category.self) var localCategories: Results<Category>
    @ObservedResults(Item.self, sortDescriptor: SortDescriptor(keyPath: "due", ascending: true)) var localItems: Results<Item>
    
    @FocusState var focused: Item?
    
    var body: some View {
        NetworkHandler { isOnline in
            NavigationView {
                SwiftUI.List {
                    ForEach(localCategories) { category in
                        CategoryCard(category: category, focused: _focused)
                            .environment(\.realm, content.realm)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                    }
                    Text("But, why tofu?")
                        .font(.footnote)
                        .listRowBackground(Color.clear)
                    Image("becausetofu")
                        .resizable()
                        .scaledToFit()
                        .safeAreaInset(edge: .bottom) {
                            Link("(image source)", destination: URL(string: "https://www.pinterest.com/pin/360076932706671722/")!)
                        }
                }
                .navigationTitle("Tofu #frvr")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NewCategoryButton()
                            .environment(\.realm, content.realm)
                            .environmentObject(content)
                    }
                    ToolbarItem(placement: .status) {
                        if isOnline.wrappedValue == false {
                            Text("\(Image(systemName: "wifi.slash")) Network is offline.\nData will sync when you return online.")
                                .bold()
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding()
                        }
                    }
                }
                .refreshable {
                    do {
                        try await content.refresh(localCategories, localItems)
                        debugPrint("Refreshed")
                    } catch {
                        await ErrorObserver.shared.handleError(error, message: "Failed refresh")
                    }
                }
                .environmentObject(content)
            }
            .onChange(of: isOnline.wrappedValue) { isBackOnline in
                // Initial value of isOnline is false, so when the NetworkHandler is instantiated and finds a network it switches 'isConnected' to 'true'.
                // We will only sync our local store (realm data) if there is a network.
                if isBackOnline {
                    Task {
                        do {
                            try await content.refresh(localCategories, localItems)
                            debugPrint("Synced data after network was connected")
                        } catch {
                            await ErrorObserver.shared.handleError(error, message: "Failed to load data after network connection was reestablished.")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
