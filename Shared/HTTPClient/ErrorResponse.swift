//
//  ErrorResponse.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import Alamofire
import ErrorHandler

public struct ErrorResponse: Error, Codable {
    let status: ResponseStatus
    let content: String
    
    var localizedDescription: String {
        content
    }
}

public extension ErrorObserver {
    func handle(_ error: ErrorResponse, showAlert: Bool = true) async {
        await ErrorObserver.shared.handleError(error, message: error.content, showAlert: showAlert)
    }
}
