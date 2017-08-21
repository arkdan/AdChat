//
//  UserListCellViewModel.swift
//  Contacts
//
//  Created by mac on 8/8/17.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol UserListCellViewModelInputs {
    var loadChatProperty: MutableProperty<Void> { get }
}

protocol UserListCellViewModelOutputs {
    var username: String { get }
    var userImage: Data { get }
    var loadChat: Signal<User, NoError> { get }
}

struct UserListCellViewModel: UserListCellViewModelInputs, UserListCellViewModelOutputs {

    let username: String
    let userImage: Data
    let loadChatProperty: MutableProperty<Void>
    var loadChat: Signal<User, NoError>

    init(user: User) {
        self.username = user.name
        self.userImage = user.avatar.imageData

        self.loadChatProperty = MutableProperty()
        let (signal, observer) = Signal<User, NoError>.pipe()

        self.loadChat = signal

        self.loadChatProperty.signal.observeValues { _ in
            observer.send(value: user)
        }
    }

    var inputs: UserListCellViewModelInputs { return self }
    var outputs: UserListCellViewModelOutputs { return self }
}
