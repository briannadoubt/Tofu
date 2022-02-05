//
//  ToFuResponse.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import Foundation

protocol ToFuResponse {
    associatedtype Content = Codable
    var status: ResponseStatus { get }
    var content: Content { get }
}
