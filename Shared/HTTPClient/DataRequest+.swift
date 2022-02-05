//
//  DataRequest.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import SwiftUI
import Alamofire

/// Lifted and modified from https://stackoverflow.com/a/68866670/9255792 (@matt is really smart, but he is also very short with ppl lol... AND also very helpful!)
public extension DataRequest {
    
    @discardableResult func responseDecodable<T: Decodable>(of type: T.Type = T.self) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            responseDecodable(of: type) { response in
                switch response.result {
                case .success(let decodedResponse):
                    continuation.resume(returning: decodedResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func responseError() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            responseDecodable(of: ErrorResponse.self) { response in
                switch response.result {
                case .success(let decodedResponse):
                    guard decodedResponse.status == .failure else {
                        continuation.resume()
                        return
                    }
                    continuation.resume(throwing: decodedResponse)
                default:
                    continuation.resume()
                }
            }
        }
    }
}
