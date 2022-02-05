//
//  Item.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import Foundation
import RealmSwift

final class Item: Object, ObjectKeyIdentifiable, Codable {
    
    @Persisted(primaryKey: true) var _id: Int
    @Persisted var name: String
    @Persisted var taskDescription: String
    @Persisted var categoryId: Int
    @Persisted var due: Date?
    @Persisted var completed: Bool
    
    @Persisted(originProperty: "items") var category: LinkingObjects<Category>
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        lhs._id == rhs._id
        && lhs.name == rhs.name
        && lhs.taskDescription == rhs.taskDescription
        && lhs.categoryId == rhs.categoryId
        && lhs.due == rhs.due
        && lhs.completed == rhs.completed
    }
    
    override init() {
        super.init()
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        __id = Persisted(wrappedValue: Int(try values.decode(String.self, forKey: ._id))!)
        
        _name = Persisted(wrappedValue: try values.decode(String.self, forKey: .name))
        
        _taskDescription = Persisted(wrappedValue: try values.decode(String.self, forKey: .taskDescription))
        
        _categoryId = Persisted(wrappedValue: Int(try values.decode(String.self, forKey: .categoryId))!)
        
        let dueString = try values.decode(String.self, forKey: .due)
        let date = ToFuApp.formatter.date(from: dueString)
        _due = Persisted(wrappedValue: date)
        
        let complete = try values.decode(String.self, forKey: .completed)
        if complete == "0" {
            _completed = Persisted(wrappedValue: false)
        } else {
            _completed = Persisted(wrappedValue: true)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(_id), forKey: ._id)
        try container.encode(name, forKey: .name)
        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(due, forKey: .due)
        try container.encode(completed, forKey: .completed)
    }
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case name
        case taskDescription = "description"
        case categoryId = "category_id"
        case due
        case completed
    }
}
