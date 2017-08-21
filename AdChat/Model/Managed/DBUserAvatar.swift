//
//  DBUserAvatar.swift
//  AdChat
//
//  Created by mac on 8/18/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import RealmSwift

final class DBUserAvatar: Object {
    dynamic var userID: String = ""
    dynamic var image: Data = Data()
}
