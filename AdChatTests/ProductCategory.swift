//
//  ProductCategory.swift
//  AdChat
//
//  Created by mac on 8/16/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation
import RealmSwift
@testable import AdChat

struct ProductCategory {
    var name: String
    var products = [Product]()

    var id: String {
        return name
    }
}

extension ProductCategory: Equatable {
    static func ==(lhs: ProductCategory, rhs: ProductCategory) -> Bool {
        return lhs.name == rhs.name
    }
}

extension ProductCategory: RealmConvertible {
    init(object: DBProductCategory) {
        name = object.name
    }
    func toObject() -> DBProductCategory {
        let object = DBProductCategory()
        object.name = name
        object.id = id
        products.forEach { object.products.append($0.managedObject()) }
        return object
    }

    func unpersistRelationships() {
        products.forEach { $0.unpersist() }
    }
}

final class DBProductCategory: AdChat.Object {
    dynamic var name: String = ""
    let products = List<DBProduct>()
}
