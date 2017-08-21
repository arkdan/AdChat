//
//  DBMessage.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import RealmSwift

class DBMessage: Object {
    dynamic var author: DBUser?
    dynamic var timestamp: Date = Date()
    dynamic var text: String? = nil
    dynamic var data: Data? = nil
}
