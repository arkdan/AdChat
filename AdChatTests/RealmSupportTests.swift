//
//  RealmSupportTests.swift
//  AdChat
//
//  Created by ark dan on 26/07/2017.
//  Copyright © 2017 ark dan. All rights reserved.
//

import XCTest
import Nimble
@testable import AdChat

import Extensions
import RealmSwift

func randomUsername() -> String {
    return "user\(arc4random_uniform(100000))"
}


class RealmSupportTests: TestCase {

    override func setUp() {
        super.setUp()

        let realm = makeRealm()
        try! realm.write {
            realm.delete(realm.objects(DBProductCategory.self))
            realm.delete(realm.objects(DBProduct.self))
        }
    }

    func testObjectAddUpdate() {

        let realm = makeRealm()

        let productNumber = 111

        var dbProduct = realm.object(ofType: DBProduct.self, forPrimaryKey: "\(productNumber)")
        expect(dbProduct).to(beNil())

        let product = Product(number: productNumber)
        product.persist()

        dbProduct = realm.object(ofType: DBProduct.self, forPrimaryKey: "\(productNumber)")
        expect(dbProduct).toNot(beNil())

        expect(Product(object: dbProduct!)) == product

        product.unpersist()
        dbProduct = realm.object(ofType: DBProduct.self, forPrimaryKey: "\(productNumber)")
        expect(dbProduct).to(beNil())
    }

    func testOneToManyAddUpdate() {

        let realm = makeRealm()

        expect(realm.objects(DBProductCategory.self).count) == 0
        expect(realm.objects(DBProduct.self).count) == 0

        var category = ProductCategory(name: "1", products: [])
        category.persist()

        category.products.append(Product(number: 1))
        category.persist()
        category.products.append(Product(number: 2))
        category.persist()

        var dbCategory = realm.object(ofType: DBProductCategory.self, forPrimaryKey: "1")
        expect(dbCategory).toNot(beNil())
        expect(dbCategory!.products.count) == 2

        category.products.remove(at: 0)
        category.persist()

        dbCategory = realm.object(ofType: DBProductCategory.self, forPrimaryKey: "1")
        expect(dbCategory!.products.count) == 1
        let dbProduct = dbCategory!.products.first!
        expect(Product(object: dbProduct)) == Product(number: 2)
    }

    func testOneToManyPersistUnpersist() {

        let realm = makeRealm()
        try! realm.write {
            realm.delete(realm.objects(DBProductCategory.self))
            realm.delete(realm.objects(DBProduct.self))
        }

        var allDBCategories = realm.objects(DBProductCategory.self)
        var allDBProducts = realm.objects(DBProduct.self)

        expect(allDBCategories.count) == 0
        expect(allDBProducts.count) == 0

        let products: (Int) -> [Product] =  { categoryNum in
            return (1...100).map { Product(number: categoryNum * 100 + $0) }
        }

        let categories = (1...10).map { ProductCategory(name: "category\($0)", products: products(Int($0))) }
        categories.forEach { $0.persist() }

        allDBCategories = realm.objects(DBProductCategory.self)
        allDBProducts = realm.objects(DBProduct.self)
        expect(allDBCategories.count) == 10
        expect(allDBProducts.count) == 10 * 100

        allDBCategories.forEach {
            expect($0.products.count) == 100
        }
    }
}

