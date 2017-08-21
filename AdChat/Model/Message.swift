//
//  Message.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation


struct Message {
    let author: User
    let content: MessageContent
    let timestamp: Date
    let id: String
}

extension Message: Equatable {
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.author == rhs.author &&
            lhs.content == rhs.content &&
            lhs.id == rhs.id
    }
}

extension Message: RealmConvertible {

    init(object: DBMessage) {
        self.author = User(object: object.author!)
        self.timestamp = object.timestamp
        self.id = object.id
        if let text = object.text {
            self.content = .text(text)
        } else if let data = object.data {
            self.content = .image(data)
        } else {
            fatalError("unsupported db message object")
        }
    }

    func toObject() -> DBMessage {
        let object = DBMessage()
        object.id = id
        object.author = author.managedObject()
        object.timestamp = timestamp
        switch content {
        case .text(let text):
            object.text = text
        case .image(let data):
            object.data = data
        }
        return object
    }
}
