//
//  DBConversation.swift
//  AdChat
//
//  Created by mac on 8/10/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import RealmSwift

final class DBConversation: Object {
    let users = List<DBUser>()
    let messages = List<DBMessage>()
}
