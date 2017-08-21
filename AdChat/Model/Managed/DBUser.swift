//
//  DBUser.swift
//  Contacts
//
//  Created by ark dan on 23/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift

final class DBUser: Object {
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var createdAt: Date = Date()
    dynamic var avatar: DBUserAvatar?
}
