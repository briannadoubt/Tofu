//
//  ContentObserver.swift
//  ToFu (iOS)
//
//  Created by Bri on 2/2/22.
//

import SwiftUI
import RealmSwift

enum ContentError: Error {
    case failedLookup
}

@MainActor class ContentObserver: ObservableObject {
    
    init(configuration: Realm.Configuration) throws {
        self.configuration = configuration
        realm = try Realm(configuration: configuration)
    }
    
    let httpClient = HTTPClient()
    let httpActor = HTTPActor(basePath: ToFuApp.basePath, formatter: ToFuApp.formatter)
    
    var realm: Realm
    
    var configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration
    
    // MARK: Items
    
    func newItem(name: String, description: String, categoryId: Int) async throws -> Item {
        
        let oneHourFromNow = Date().addingTimeInterval(60 * 60)
        
        let addItemResult = try await httpActor.addItem(
            name: name,
            description: description,
            categoryId: categoryId,
            due: oneHourFromNow
        )
        
        let newItemId = addItemResult.content
        
        let newItem = Item()
        newItem._id = newItemId
        newItem.categoryId = categoryId
        newItem.due = oneHourFromNow
        newItem.name = name
        newItem.taskDescription = description
        
        return newItem
    }
    
    func updateItem(_ item: Item) async throws {
        let _ = realm.thaw()
        let response = try await httpActor.updateItem(item._id, name: item.name, description: item.taskDescription, categoryId: item.categoryId, due: item.due, completed: item.completed)
        let _ = realm.freeze()
        debugPrint(response.status, response.content)
    }
    
    func deleteItem(_ item: Item) async throws {
        let response = try await httpActor.deleteItem(item._id)
        try realm.write {
            print(item._id)
            let matchingItems = realm.objects(Item.self).where {
                $0._id == item._id
            }
            print(matchingItems)
            realm.delete(matchingItems)
        }
        print(response.status, response.content)
    }
    
    // MARK: Categories
    
    func newCategory(name: String) async throws -> Category {
        
        let addCategoryResult = try await httpActor.addCategory(name: name)
        
        let newCategoryId = addCategoryResult.content
        
        let newCategory = Category()
        newCategory._id = newCategoryId
        newCategory.name = name
        
        return newCategory
    }
    
    func updateCategory(_ id: Int, name: String) async throws {
        let result = try await httpActor.updateCategory(id, name: name)
        debugPrint(result.status, result.content)
    }
    
    func deleteCategory(_ id: Int) async throws {
        let result = try await httpActor.deleteCategory(id)
        print(result.status, result.content)
    }
    
    // MARK: Collection Handlers
    
    /// Called when the client wants to refresh the data. This function downloads new collections and items from the server, and initiates the cache/merging logic.
    func refresh(_ localCategories: Results<Category>, _ localItems: Results<Item>) async throws {
        
        // Get new data
        let (newCategories, newItems) = try await httpActor.get()
        
        // Realm -> Server
        try syncLocalDataToServer(newCategories, newItems, localCategories, localItems)
        
        // Realm <- Server
        try await mergeNewDataIntoLocalStore(newCategories, newItems, localCategories, localItems)
    }
    
    /// Look at all the local data and determine what is missing, then make the API calls necessary to update the server.
    func syncLocalDataToServer(_ newCategories: [Category], _ newItems: [Item], _ localCategories: Results<Category>, _ localItems: Results<Item>) throws {
        
        if localCategories.isEmpty {
            return
        }
        
        // Sync localCategories
        for localCategory in localCategories { // MARK: <- RLMCollection iterating issue throws here!
            if localCategory.isInvalidated {
                Task {
                    try await deleteCategory(localCategory._id)
                }
            }
            if let index = newCategories.firstIndex(where: { $0._id == localCategory._id }) {
                
                // Category exists on server
                
                if localCategory == newCategories[index] {
                    // Category has not been changed.
                    return
                }
                
                // Category has been changed. Update it.
                Task {
                    let updateCategoryResponse = try await httpActor.updateCategory(localCategory._id, name: localCategory.name)
                    debugPrint(updateCategoryResponse.status.rawValue, updateCategoryResponse.content)
                }
            
            } else {
                Task {
                    // Category does not exist on the server. Upload it.
                    let newCategory = try await newCategory(name: localCategory.name)
                
                    // The old localCategory didn't have a valid id, this one does.
                    // Realm doesn't allow rewriting a primary key (cause yeah don't do that)
                    // so we must delete the old one and ressurect the new!
                    try realm.write {
                        realm.delete(realm.objects(Category.self).filter({ $0._id == localCategory._id }))
                        realm.add(newCategory, update: .modified)
                    }
                }
            }
        }
        
        // Sync localItems
        for localItem in localItems {
            if let index = newItems.firstIndex(where: { $0._id == localItem._id }) {
                // Item exists on server
                if localItem == newItems[index] {
                    // Category has not been changed.
                    return
                }
                // Item has been changed. Update it.
                Task {
                    let updateItemResponse = try await httpActor.updateItem(localItem._id, name: localItem.name, description: localItem.taskDescription, categoryId: localItem.categoryId, due: localItem.due, completed: localItem.completed)
                    debugPrint(updateItemResponse.status.rawValue, updateItemResponse.content)
                }
                
            } else {
                Task {
                    // Category does not exist on the server. Upload it.
                    let newItem = try await newItem(name: localItem.name, description: localItem.taskDescription, categoryId: localItem.categoryId)
                
                    // The old localCategory didn't have a valid id, this one does.
                    // Realm doesn't allow rewriting a primary key (cause yeah don't do that)
                    // so we must delete the old one and ressurect the new!
                    try realm.write {
                        realm.delete(realm.objects(Item.self).filter({ $0._id == localItem._id }))
                        realm.add(newItem, update: .modified)
                    }
                }
            }
        }
    }
    
    /// Save and map new data to Realm
    func mergeNewDataIntoLocalStore(_ newCategories: [Category], _ newItems: [Item], _ localCategories: Results<Category>, _ localItems: Results<Item>) async throws {
        
        // If the data is the same as what's on disk, return now
        if localCategories.elementsEqual(newCategories) {
            debugPrint("Categories have not changed.")
            return
        }
        if localItems.elementsEqual(newItems) {
            debugPrint("Items have not changed.")
            return
        }
        
        // Load our instance of Realm
        let realm = realm
        
        // Save new data to Realm with the `.modified` update strategy so that new data is loaded into our super fancy bindable ORM schema atomically! 🥳
        try realm.write {
            
            // Save new Items to Realm
            realm.add(newItems, update: .modified)
            
            // Map items to categories
            for newItem in newItems {
                
                if newItem._id < 1 {
                    // Invalid id, can't really do much with these...
                    // This was a decision I made to clean up the database.
                    // If we were in production I would have probably made an interface for the user to manage these invalid items themselves, given some more time.
                    continue
                }
                
                if let newItemCategory = newCategories.first(where: { return $0._id == newItem.categoryId }) {
                    newItemCategory.items.append(newItem)
                    realm.add(newItemCategory, update: .modified)
                }
            }
            // Save Categories with mapped items to Realm
            // Check if it is managed or not, and if not, save into Realm
            realm.add(newCategories.filter({ $0.realm == nil }), update: .modified)
        }
    }
}
