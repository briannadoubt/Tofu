//
//  HTTPClient.swift
//  ToFu (iOS)
//
//  Created by Bri on 2/2/22.
//

import Foundation
import Alamofire
import RealmSwift

/// This file contains a commented out alternative approach that I thought of for caching and recalling offline activity once a network is found.
/// It didn't quite work due to needing to store a type definition in realm, which got complicated, so I implemented an 'upload new and modified, delete missing' logic.

//final class OfflineRequest: Object, ObjectKeyIdentifiable {
//
//    @Persisted(primaryKey: true) var id: ObjectId
//
//    @Persisted var parameters: Map<String, String>
//    @Persisted var url: String
//    @Persisted var method: String
//
//}

actor HTTPClient {
    
    /// Makes all the HTTP requests for ToFu with Alamofire.
    /// If the client is offline (no internet connection is found), cache the offline request to a local realm.
    /// Once the client comes back online they are expected to make all the cached requests before performing any further requests.
    ///
    /// Only, I ran out of time! I'll leave what I got and we can talk about it.
//    func makeRequest<T: Decodable>(of: T.Type = T.self, isOnline: Bool, _ request: ToFuURLRequest, cacheTo realm: Realm) async throws -> T? {
    func makeRequest<T: Decodable>(of: T.Type = T.self, _ request: HTTPURLRequest) async throws -> T {
//        if isOnline {
        print(request.urlRequest?.debugDescription)
        let task = AF.request(request).validate()
        try await task.responseError()
        return try await task.responseDecodable(of: T.self)
//        } else {
//            try realm.write {
//                realm.add(request)
//            }
//            return nil
//        }
    }
}
