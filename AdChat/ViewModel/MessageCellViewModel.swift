//
//  MessageCellViewModel.swift
//  AdChat
//
//  Created by mac on 8/11/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation

protocol MessageCellViewModelInputs {
}

protocol MessageCellViewModelOutputs {
    var messageInfo: MessageInfo { get }
    var isOwn: Bool { get }
    var avatar: Data? { get }
}

struct MessageCellViewModel: MessageCellViewModelInputs, MessageCellViewModelOutputs {
    let messageInfo: MessageInfo
    let isOwn: Bool
    let avatar: Data?
}

extension MessageCellViewModel {
    init(message: Message) {
        self.messageInfo = MessageInfo(message)
        self.isOwn = message.author == Session.shared.currentUser.value.flatMap { $0 }
        self.avatar = message.author.avatar.imageData
    }
}
