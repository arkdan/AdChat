//
//  LoginViewModel.swift
//  Contacts
//
//  Created by ark dan on 24/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Extensions


protocol LoginViewModelInputs {
    var usernameProperty: MutableProperty<String?> { get }
    var loginPressed: MutableProperty<Void> { get }
}

protocol LoginViewModelOutputs {
    var loginEnabled: SignalProducer<Bool, NoError> { get }
    var title: String { get }
    var imageName: String { get }

    var loggedIn: ((User) -> Void)? { get set }
}

final class LoginViewModel: LoginViewModelInputs, LoginViewModelOutputs {

    let usernameProperty = MutableProperty<String?>(nil)
    let emailProperty = MutableProperty<String?>(nil)
    let loginPressed = MutableProperty()

    let loginEnabled: SignalProducer<Bool, NoError>

    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }

    var title: String {
        return "Conversations"
    }

    var imageName: String {
        return "contacts-icon"
    }

    var loggedIn: ((User) -> Void)?

    init() {
        let allowLogin: (String?) -> Bool = { $0 == nil ? false : $0!.characters.count >= 5 }

        let loginData = usernameProperty.producer

        loginEnabled = loginData.map(allowLogin)

        loginData
            .sample(on: loginPressed.signal)
            .skipNil()
            .filter(allowLogin)
            .flatMap(.concat, { User.load(name: $0) })
            .startWithValues { user in
                user.persist()
                Session.shared.currentUser.value = user
        }
    }

}

