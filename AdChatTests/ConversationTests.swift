//
//  ConversationTests.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import XCTest
import Nimble
import Extensions
@testable import AdChat

class ConversationTests: TestCase {

    func testUsersMessages() {

        // 3 users in a conversation
        let users = (0..<3)
            .map { _ in User(name: randomUsername()) }
            .sorted { $0.name < $1.name }

        let messages: [Message] = (0..<100)
            .map { index in
                let author = users.any()
                let content = "\(index)" + author.name
                let message = Message(author: author, content: .text(content), timestamp: Date(), id: UUID().uuidString)
                return message
            }
            .sorted { $0.timestamp < $1.timestamp }

        let id = randomUsername()
        let conversation = Conversation(users: users, messages: messages, id: id)
        conversation.persist()

        let dbConversation = makeRealm().object(ofType: DBConversation.self, forPrimaryKey: id)
        expect(dbConversation).toNot(beNil())

        let testUsers = dbConversation!.users
            .map { User(object: $0) }
            .sorted { $0.name < $1.name }

        let testMessages = dbConversation!.messages
            .map { Message(object: $0) }
            .sorted { $0.timestamp < $1.timestamp }

        expect(users) == testUsers
        expect(messages) == testMessages
    }

    func testLoadExisting() {

        let users = (0..<3)
            .map { _ in User(name: randomUsername()) }
            .sorted { $0.name < $1.name }

        var conversation = Conversation.load(participants: users)
        expect(conversation).to(beNil())

        Conversation.new(participants: users).persist()
        conversation = Conversation.load(participants: users)
        expect(conversation).toNot(beNil())

        expect(conversation?.users) == users
    }

}
