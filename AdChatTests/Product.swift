//
//  File.swift
//  AdChat
//
//  Created by mac on 8/16/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import RealmSwift
@testable import AdChat

struct Product {
    var number: Int

    var id: String {
        return "\(number)"
    }
}

extension Product: Equatable {
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.number == rhs.number
    }
}

extension Product: RealmConvertible {
    init(object: DBProduct) {
        number = object.number
    }
    func toObject() -> DBProduct {
        let object = DBProduct()
        object.number = number
        object.id = id
        return object
    }
}

final class DBProduct: AdChat.Object {
    dynamic var number: Int = 0

    convenience init(number: Int) {
        self.init()
        self.number = number
        self.id = "\(number)"
    }
}
