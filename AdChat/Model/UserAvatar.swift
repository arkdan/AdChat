//
//  UserAvatar.swift
//  AdChat
//
//  Created by mac on 8/18/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation

struct UserAvatar {
    let imageData: Data
    let userID: String

    var id: String {
        return userID
    }
}

extension UserAvatar: RealmConvertible {

    init(object: DBUserAvatar) {
        self.imageData = object.image
        self.userID = object.userID
    }

    func toObject() -> DBUserAvatar {
        let object = DBUserAvatar()
        object.image = imageData
        object.userID = userID
        object.id = id
        return object
    }
}
