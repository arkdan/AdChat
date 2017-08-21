//
//  ConversationViewModel.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import RealmSwift

protocol ConversationViewModelInputs {
    func send(content: MessageContent)
    func add(message: Message)
    func add(messages: [Message])
}

protocol ConversationViewModelOutputs {
    var participants: [String] { get }
    var messages: [MessageCellViewModel] { get }
    var newMessageSignal: Signal<Int, NoError> { get }
    var title: String { get }
}

final class ConversationViewModel: ConversationViewModelInputs, ConversationViewModelOutputs {

    private var conversation: Conversation

    var messages: [MessageCellViewModel] {
        return conversation.messages.map { MessageCellViewModel(message: $0) }
    }
    let newMessageSignal: Signal<Int, NoError>

    var participants: [String] {
        return conversation.users.map { $0.name }
    }

    let title: String

    init(conversation: Conversation) {
        self.conversation = conversation

        self.newMessageSignal = conversation.managedObject().messages
            .valueAdded()
            .map { $0.1 }

        let names = conversation.users
            .filter { $0 != Session.shared.currentUser.value! }
            .map { $0.name }
        title = names.joined(separator: ", ")
    }

    /// Creates ViewModel with loaded conversation with participants; or creates new Conversation
    /// if there is no conversation history for these participants
    class func load(with participants: [User]) -> ConversationViewModel {

        let conversation: Conversation

        if let c = Conversation.load(participants: participants) {
            conversation = c
        } else {
            conversation = Conversation.new(participants: participants)
        }

        return ConversationViewModel(conversation: conversation)
    }

    func send(content: MessageContent) {
        guard let author = Session.shared.currentUser.value else { return }
        let message = Message(author: author, content: content, timestamp: Date(), id: UUID().uuidString)
        add(message: message)
    }

    func add(message: Message) {
        conversation.messages.append(message)
        conversation.persist()
    }

    func add(messages: [Message]) {
        conversation.messages.append(contentsOf: messages)
        conversation.persist()
    }

    var inputs: ConversationViewModelInputs { return self }
    var outputs: ConversationViewModelOutputs { return self }
}
