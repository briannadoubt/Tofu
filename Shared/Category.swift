//
//  Category.swift
//  ToFu
//
//  Created by Bri on 2/2/22.
//

import RealmSwift

final class Category: Object, ObjectKeyIdentifiable, Codable {
    
    @Persisted(primaryKey: true) var _id: Int
    @Persisted var name: String
    @Persisted var items = RealmSwift.List<Item>()
    
    static func ==(lhs: Category, rhs: Category) -> Bool {
        lhs._id == rhs._id
        && lhs.name == rhs.name
    }
    
    override init() {
        super.init()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        __id = Persisted(wrappedValue: Int(try values.decode(String.self, forKey: ._id))!, primaryKey: true)
        _name = Persisted(wrappedValue: try values.decode(String.self, forKey: .name))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(name, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case name = "name"
    }
}
