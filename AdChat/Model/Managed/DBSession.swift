//
//  DBSession.swift
//  Contacts
//
//  Created by ark dan on 24/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift

final class DBSession: Object {
    dynamic var user: DBUser?
}
