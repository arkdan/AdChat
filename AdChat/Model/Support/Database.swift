//
//  Database.swift
//  AdChat
//
//  Created by mac on 8/21/17.
//  Copyright © 2017 Arkadi Daniyelian. All rights reserved.
//

import Foundation
import RealmSwift

private var databaseVersion: UInt64 {
    return 12
}

extension Realm {

    final class func migrate(to version: UInt64 = databaseVersion) {
        Configuration.defaultConfiguration.schemaVersion = version
    }
}

var makeRealm: () -> Realm = {
    return try! Realm()
}
