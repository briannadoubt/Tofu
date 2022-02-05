//
//  ToFuApp.swift
//  Shared
//
//  Created by Bri on 2/1/22.
//

import SwiftUI
import ErrorHandler
import RealmSwift

@main
struct ToFuApp: SwiftUI.App {
    
    init() {
        do {
            let realmConfiguration = Realm.Configuration(
                inMemoryIdentifier: "com.brainnadoubt.ToFu.realm",
                schemaVersion: 6
            )
            self.realmConfiguration = realmConfiguration
            let newObserver = try ContentObserver(configuration: self.realmConfiguration)
            _content = StateObject(wrappedValue: newObserver)
        } catch let error as ToFuAppError {
            fatalError(error.localizedDescription)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    @StateObject var content: ContentObserver
    
    let realmConfiguration: Realm.Configuration
    
    var body: some Scene {
        WindowGroup {
            ErrorHandler {
                ContentView()
                    .environment(\.realmConfiguration, realmConfiguration)
                    .environment(\.realm, content.realm)
                    .environmentObject(content)
            }
        }
    }
}

extension ToFuApp {
    
    static var basePath = "https://api.fusionofideas.com/todo/"
    
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}

enum ToFuAppError: String, Error {
    
    case keychainInsertionFailed = "Failed to insert the new key in the keychain"
    
    var localizedDescription: String {
        rawValue
    }
}
