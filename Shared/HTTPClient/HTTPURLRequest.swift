//
//  ItemURLRequest.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import Foundation
import Alamofire
import RealmSwift

enum HTTPURLRequest: URLRequestConvertible {
    
    case getItems
    case addItem(_ name: String, _ description: String, _ categoryId: Int, _ due: Date)
    case deleteItem(_ id: Int)
    case updateItem(_ id: Int, name: String, description: String, categoryId: Int, due: Date, completed: Bool)
    
    case getCategories
    case addCategory(_ name: String)
    case deleteCategory(_ id: Int)
    case updateCategory(_ id: Int, name: String)
    
    var baseURL: URL {
        URL(string: "https://api.fusionofideas.com/todo/")!
    }
    
    var path: String {
        let php = ".php"
        var path: String
        switch self {
        case .getItems:
            path = "getItems"
        case .addItem:
            path = "addItem"
        case .deleteItem:
            path = "deleteItem"
        case .updateItem:
            path = "updateItem"
            
        case .getCategories:
            path = "getCategories"
        case .addCategory:
            path = "addCategory"
        case .deleteCategory:
            path = "deleteCategory"
        case .updateCategory:
            path = "updateCategory"
        }
        return path + php
    }
    
    var method: HTTPMethod {
        switch self {
        case .getItems:
            return .get
        case .addItem:
            return .post
        case .deleteItem:
            return .delete
        case .updateItem:
            return .put
            
        case .getCategories:
            return .get
        case .addCategory:
            return .post
        case .deleteCategory:
            return .post //.delete
        case .updateCategory:
            return .post //.put
        }
    }
    
    // In production this would be a thing...
    // Buuuuut this is a code challenge so they all return nil 🤪
    var headers: HTTPHeaders? {
        return nil
    }
    
    func asURLRequest() throws -> URLRequest {
        
        var request = try URLRequest(
            url: baseURL.appendingPathComponent(path),
            method: method,
            headers: headers
        )

        let encoder = URLEncodedFormParameterEncoder(
            encoder: URLEncodedFormEncoder(
                alphabetizeKeyValuePairs: false,
                arrayEncoding: .indexInBrackets,
                boolEncoding: .numeric,
                dataEncoding: .deferredToData,
                dateEncoding: .custom(ToFuApp.formatter.string(from:)),
                keyEncoding: .useDefaultKeys,
                spaceEncoding: .percentEscaped
            ),
            destination: .queryString
        )
        
        switch self {
        case .getItems, .getCategories:
            break
        
        case .deleteItem(let id), .deleteCategory(let id):
            request = try encoder.encode(["id": id], into: request)
        
        case .updateItem(let id, let name, let description, let categoryId, let due, let completed):
            let parameters = [
                "id": "\(id)",
                "name": name,
                "description": description,
                "category_id": "\(categoryId)",
                "due": ToFuApp.formatter.string(from: due),
                "completed": completed ? "1" : "0"
            ]
            print(parameters)
            request = try encoder.encode(parameters, into: request)
            print(request)
        
        case .updateCategory(let id, let name):
            let parameters: [String: String] = [
                "id": "\(id)",
                "name": name
            ]
            request = try encoder.encode(parameters, into: request)
            
        case .addItem(let name, let description, let categoryId, let due):
            let parameters = [
                "name": name,
                "description": description,
                "category_id": "\(categoryId)",
                "due": ToFuApp.formatter.string(from: due),
            ]
            request = try encoder.encode(parameters, into: request)
            print(request)
        
        case .addCategory(let name):
            request = try encoder.encode(["name": name], into: request)
        }
        
        return request
    }
}
