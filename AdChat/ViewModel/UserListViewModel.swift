//
//  UserListViewModel.swift
//  Contacts
//
//  Created by ark dan on 26/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import RealmSwift

protocol UserListViewModelInputs {
    func exit()
}

protocol UserListViewModelOutputs {
    var currentUserNameImage: SignalProducer<(String?, Data?), NoError> { get }
    var cells: SignalProducer<[UserListCellViewModel], NoError> { get }
    var startChat: Signal<ConversationViewModel, NoError> { get }
}

final class UserListViewModel: UserListViewModelInputs, UserListViewModelOutputs {

    let startChat: Signal<ConversationViewModel, NoError>

    let cells: SignalProducer<[UserListCellViewModel], NoError>

    let currentUserNameImage: SignalProducer<(String?, Data?), NoError>

    init(user: User?) {

        self.currentUserNameImage = Session.shared.currentUser.producer
            .map { ($0?.name, $0?.avatar.imageData) }

        let (signal, observer) = Signal<ConversationViewModel, NoError>.pipe()
        self.startChat = signal

        let currentUser = Session.shared.currentUser.producer

        let allUsers = makeRealm().observeObjects(ofType: DBUser.self)
            .toModelArray(User.self)
            .map { $0.sorted { $0.name < $1.name } }

        let filterCurrent: ([User], User?) -> [User] = { (all, current) -> [User] in
            guard let current = current else {
                return all
            }
            return all.filter { $0 != current }
        }

        let createCellViewModel: (User) -> UserListCellViewModel = { user in
            let cellViewModel = UserListCellViewModel(user: user)
            cellViewModel.outputs.loadChat.observeValues { participant in
                guard let currentUser = Session.shared.currentUser.value else { return }

                let participants = [currentUser, participant]
                observer.send(value: ConversationViewModel.load(with: participants))
            }
            return cellViewModel
        }

        self.cells = allUsers.combineLatest(with: currentUser)
            .map { filterCurrent($0, $1) }
            .map { $0.map { createCellViewModel($0) } }
    }

    func addUser(name: String) {
        let user = User(name: name)
        user.persist()
    }

    func exit() {
        Session.shared.currentUser.value = nil
    }

    var inputs: UserListViewModelInputs { return self }
    var outputs: UserListViewModelOutputs { return self }
}
