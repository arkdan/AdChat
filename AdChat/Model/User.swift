//
//  User.swift
//  Contacts
//
//  Created by ark dan on 22/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import Result

struct User {
    let name: String
    let email: String
    let createdAt: Date
    var avatar: UserAvatar

    var conversations: SignalProducer<[Conversation], NoError> {
        return makeRealm().objects(DBConversation.self).signalProducer()
            .toModelArray(Conversation.self)
            .map { $0.filter { $0.users.contains(self) } }
    }

    var id: String {
        return email
    }
}

extension User {
    init(name: String) {
        self.name = name
        self.email = "\(name)@example.com"
        self.createdAt = Date()
        self.avatar = .noAvatar
    }
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name &&
            lhs.email == rhs.email
    }
}

extension User: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}

extension User: RealmConvertible {

    func toObject() -> DBUser {
        let object = DBUser()
        object.id = id
        object.name = name
        object.email = email
        object.createdAt = createdAt
        object.avatar = avatar.managedObject()
        return object
    }

    init(object: DBUser) {
        name = object.name
        email = object.email
        createdAt = object.createdAt
        avatar = UserAvatar(object: object.avatar!)
    }

    func unpersistRelationships() {
        avatar.unpersist()
    }
}
