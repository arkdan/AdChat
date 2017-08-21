//
//  ChatListViewModel.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol ChatListViewModelInputs {
    func startConversation(participants: [User])
}

protocol ChatListViewModelOutputs {
    var cells: SignalProducer<[ChatListCellViewModel], NoError> { get }
    var isEmpty: SignalProducer<Bool, NoError> { get }
    var loadChat: Signal<ConversationViewModel, NoError> { get }
}

final class ChatListViewModel: ChatListViewModelInputs, ChatListViewModelOutputs {

    let cells: SignalProducer<[ChatListCellViewModel], NoError>
    let isEmpty: SignalProducer<Bool, NoError>

    let loadChat: Signal<ConversationViewModel, NoError>
    private let loadChatObserver: Signal<ConversationViewModel, NoError>.Observer

    init() {

        // coordination
        let (signal, observer) = Signal<ConversationViewModel, NoError>.pipe()

        self.loadChat = signal
        self.loadChatObserver = observer


        // cells
        self.cells = SignalProducer { observer, lifetime in
            Session.shared.currentUser.producer.startWithValues { user in
                guard let user = user else {
                    observer.send(value: [])
                    return
                }

                user.conversations
                    .map { $0.filter { $0.messages.count != 0 } }
                    .startWithValues { conversations in
                    let cellViewModels = conversations
                        .map { ChatListCellViewModel(conversation: $0) }
                    observer.send(value: cellViewModels)
                }
            }
        }

        self.isEmpty = self.cells.map { $0.isEmpty }
    }

    func startConversation(participants: [User]) {
        guard let currentUser = Session.shared.currentUser.value else {
            fatalError("how about sing in first?")
        }

        let conversationViewModel = ConversationViewModel.load(with: participants.appending(currentUser))
        loadChatObserver.send(value: conversationViewModel)
    }

    var inputs: ChatListViewModelInputs { return self }
    var outputs: ChatListViewModelOutputs { return self }
}
