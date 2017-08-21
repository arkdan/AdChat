//
//  UserAvatarLoad.swift
//  AdChat
//
//  Created by mac on 8/18/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import ReactiveSwift
import Result

extension User {

    static func load(name: String) -> SignalProducer<User, NoError> {

        return SignalProducer { observable, lifetime in

            var user = User(name: name)

            let completed = {
                observable.send(value: user)
                observable.sendCompleted()
            }

            if let stored = makeRealm().object(ofType: DBUserAvatar.self, forPrimaryKey: user.id) {
                user.avatar = UserAvatar(object: stored)
                completed()
            }

            Alamofire.request(URL(string: "https://randomuser.me/api/?inc=picture&noinfo")!).responseJSON { response in
                guard response.result.isSuccess,
                    let result = response.result.value as? [String: [[String: [String: String]]]],
                    let url = result["results"]?[0]["picture"]?["large"] else {
                        completed()
                        return
                }

                Alamofire.request(URL(string: url)!).responseData { response in
                    guard response.result.isSuccess,
                        let data = response.data else {
                            completed()
                            return
                    }
                    user.avatar = UserAvatar(imageData: data, userID: user.id)
                    completed()
                }
            }
        }
    }
}

extension UserAvatar {

    static var noAvatar: UserAvatar {
        let url = Bundle.main.url(forResource: "noAvatar", withExtension: "png")!
        let data = try! Data(contentsOf: url)
        return UserAvatar(imageData: data, userID: "")
    }
}
