//
//  Conversation.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

struct Conversation {

    var users = [User]()
    var messages = [Message]()

    let id: String

    var messagesSignalProducer: SignalProducer<[Message], NoError> {
        return managedObject().messages.signalProducer().toModelArray(Message.self)
    }

    static func new(participants: [User]) -> Conversation {
        return Conversation(users: participants, messages: [], id: UUID().uuidString)
    }

    static func load(participants: [User]) -> Conversation? {
        let filter: (DBConversation) -> Bool = { dbConversation in
            let conversationParticipants: [User] = dbConversation.users.map { User(object: $0) }
            return Set(participants).isSubset(of: Set(conversationParticipants))
        }
        if let found = makeRealm().objects(DBConversation.self).filter(filter).last {
            return Conversation(object: found)
        }

        return nil
    }
}

extension Conversation: RealmConvertible {

    init(object: DBConversation) {
        self.id = object.id
        self.users = object.users.map { User(object: $0) }
        self.messages = object.messages.map { Message(object: $0) }
    }

    func toObject() -> DBConversation {
        let object = DBConversation()
        object.id = id
        users.forEach { object.users.append($0.managedObject()) }
        messages.forEach { object.messages.append($0.managedObject()) }
        return object
    }

    func unpersist() {
        messages.forEach { $0.unpersist() }
    }
}
