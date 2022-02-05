//
//  CategoriesActor.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import Foundation
import Alamofire

@MainActor class HTTPActor {
    
    nonisolated init(basePath: String, formatter: DateFormatter) {
        self.basePath = basePath
        self.formatter = formatter
    }
    
    let basePath: String
    let formatter: DateFormatter
    
    let client = HTTPClient()
    
    func get() async throws -> ([Category], [Item]) {
        (try await getCategories().content, try await getItems().content)
    }
    
    // MARK: Get Items

    func getItems() async throws -> ItemsResponse {
        return try await client.makeRequest(.getItems)
    }
    
    struct ItemsResponse: Codable {
        let status: ResponseStatus
        let content: [Item]
    }
    
    // MARK: Add Item
    
    func addItem(name: String, description: String, categoryId: Int, due: Date?) async throws -> AddItemResponse {
        return try await client.makeRequest(.addItem(name, description, categoryId, due ?? Date()))
    }
    
    struct AddItemResponse: Codable {
        let status: ResponseStatus
        let content: Int
    }
    
    // MARK: Delete Item
    
    func deleteItem(_ id: Int) async throws -> DeleteItemResponse {
        return try await client.makeRequest(.deleteItem(id))
    }
    
    struct DeleteItemResponse: Codable {
        let status: ResponseStatus
        let content: String
    }
    
    // MARK: Update Item
    
    func updateItem(_ id: Int, name: String, description: String, categoryId: Int, due: Date?, completed: Bool) async throws -> UpdateItemResponse {
        try await client.makeRequest(.updateItem(id, name: name, description: description, categoryId: categoryId, due: due ?? Date(), completed: completed))
    }
    
    struct UpdateItemResponse: Codable {
        let status: ResponseStatus
        let content: String
    }
    
    // MARK: Get Categories
    
    func getCategories() async throws -> CategoriesResponse {
        return try await client.makeRequest(.getCategories)
    }
    
    struct CategoriesResponse: Codable {
        let status: ResponseStatus
        let content: [Category]
    }
    
    // MARK: Add Category
    
    func addCategory(name: String) async throws -> AddCategoryResponse {
        return try await client.makeRequest(.addCategory(name))
    }
    
    struct AddCategoryResponse: Codable {
        let status: ResponseStatus
        let content: Int
    }
    
    // MARK: Delete Category
    
    func deleteCategory(_ id: Int) async throws -> DeleteCategoryResponse {
        return try await client.makeRequest(.deleteCategory(id))
    }
    
    struct DeleteCategoryResponse: Codable {
        let status: ResponseStatus
        let content: String
    }
    
    // MARK: Update Category
    
    func updateCategory(_ id: Int, name: String) async throws -> UpdateCategoryResponse {
        return try await client.makeRequest(.updateCategory(id, name: name))
    }
    
    struct UpdateCategoryResponse: Codable {
        let status: ResponseStatus
        let content: String
    }
}
