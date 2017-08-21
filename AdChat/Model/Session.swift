//
//  Session.swift
//  Contacts
//
//  Created by ark dan on 24/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import Result

final class Session {

    let currentUser: MutableProperty<User?>

    fileprivate init(user: User?) {
        self.currentUser = MutableProperty(user)

        // listen to current user changes and update db single session object
        self.currentUser.signal
            .skipRepeats { $0 == $1 }
            .observeValues { self.setUser($0) }
    }

    private func setUser(_ user: User?) {
        let dbSession = managedObject()
        let dbUser = user?.managedObject()
        try! makeRealm().write {
            dbSession.user = dbUser
        }
    }

    static let shared: Session = {
        if let persisted = makeRealm().objects(DBSession.self).last {
            return Session(object: persisted)
        }

        let session = Session(user: nil)
        session.persist()

        return session
    }()
}

extension Session: RealmConvertible {

    convenience init(object: DBSession) {
        self.init(user: object.user.flatMap { User(object: $0) })
    }

    func toObject() -> DBSession {
        let object = DBSession()
        object.user = currentUser.value?.managedObject()
        return object
    }

    var id: String {
        return ""
    }
}
