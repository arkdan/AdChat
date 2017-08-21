//
//  ChatListCellViewModel.swift
//  AdChat
//
//  Created by mac on 8/11/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol ChatListCellViewModelInputs {
    var deleteConversation: MutableProperty<Void> { get }
}

protocol ChatListCellViewModelOutputs {
    var lastMessage: SignalProducer<MessageInfo?, NoError> { get }
    var messagesCount: SignalProducer<Int, NoError> { get }
    var usersExceptMe: [User] { get }
}

struct ChatListCellViewModel: ChatListCellViewModelInputs, ChatListCellViewModelOutputs {

    let lastMessage: SignalProducer<MessageInfo?, NoError>
    let messagesCount: SignalProducer<Int, NoError>
    let deleteConversation: MutableProperty<Void>

    let usersExceptMe: [User]

    init(conversation: Conversation) {
        guard let currentUser = Session.shared.currentUser.value else {
            fatalError("sign in first?")
        }
        self.usersExceptMe = conversation.users.filter { $0 != currentUser }

        self.lastMessage = conversation.messagesSignalProducer
            .map { $0.last }
            .map { $0.flatMap { MessageInfo($0) } }
        self.messagesCount = conversation.messagesSignalProducer.map { $0.count }

        self.deleteConversation = MutableProperty()

        self.deleteConversation.signal.observeValues {
            guard let currentUser = Session.shared.currentUser.value,
                let index = conversation.users.index(of: currentUser) else {
                    return
            }
            var copy = conversation
            copy.users.remove(at: index)
            if copy.users.isEmpty {
                copy.unpersist()
            } else {
                copy.persist()
            }
        }
    }

    var inputs: ChatListCellViewModelInputs { return self }
    var outputs: ChatListCellViewModelOutputs { return self }
}
