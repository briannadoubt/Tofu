//
//  Realm+.swift
//  ToFu (iOS)
//
//  Created by Bri on 2/2/22.
//

import RealmSwift

extension Realm {
    @discardableResult
    public func write<Result>(withoutNotifying tokens: [NotificationToken] = [], _ block: (() async throws -> Result)) async throws -> Result {
        beginWrite()
        var ret: Result!
        do {
            ret = try await block()
        } catch let error {
            if isInWriteTransaction { cancelWrite() }
            throw error
        }
        if isInWriteTransaction { try commitWrite(withoutNotifying: tokens) }
        return ret
    }
}
