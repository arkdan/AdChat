//
//  RealmProducerTests.swift
//  AdChat
//
//  Created by ark dan on 30/07/2017.
//  Copyright © 2017 ark dan. All rights reserved.
//

import XCTest
import Nimble
@testable import AdChat

class RealmProducerTests: TestCase {
    
    override func setUp() {
        super.setUp()
        let realm = makeRealm()
        try! realm.write {
            realm.delete(realm.objects(DBProduct.self))
        }
    }

    func testObjectsAdd() {
        let exp = expectation(description: #function)
        let realm = makeRealm()

        expect(realm.objects(DBProduct.self).count) == 0

        var count = 0

        let disposable = realm.objects(DBProduct.self).valueAdded()
            .observeValues { object in
                switch count {
                case 0:
                    expect(object.number) == 10
                case 1:
                    expect(object.number) == 20
                    exp.fulfill()
                default:
                    fail()
                }
                count += 1
        }

        let obj1 = DBProduct(number: 10)
        let obj2 = DBProduct(number: 20)

        try! realm.write {
            realm.add(obj1, update: true)
            realm.add(obj2, update: true)
        }

        waitForExpectations(timeout: 1000.1, handler: { _ in disposable?.dispose() })
    }

    func testResultsChange() {
        let exp = expectation(description: #function)
        let realm = makeRealm()

        expect(realm.objects(DBProduct.self).count) == 0

        let results = realm.objects(DBProduct.self)

        var count = 0

        var productsTest1: [Product] = []
        var productsTest2: [Product] = []

        let disposable = results.signalProducer().toModelArray(Product.self)
            .map { $0.sorted { $0.number < $1.number } }
            .startWithValues { products in
                switch count {
                case 0:
                    expect(products) == []
                case 1:
                    expect(products) == productsTest1
                case 2:
                    expect(products) == productsTest2
                    exp.fulfill()
                default:
                    fail()
                }
                count += 1
        }

        let objects = (10..<20).map {  DBProduct(number: $0) }

        productsTest1 = objects.map { Product(object: $0) }

        // count 0: add 10 objects
        try! realm.write {
            objects.forEach { realm.add($0, update: true) }
        }
        var objectsCopy = objects
        objectsCopy.removeSubrange(2...4)
        productsTest2 = objectsCopy.map { Product(object: $0) }

        // count 1: remove 3 objects
        try! realm.write {
            realm.delete(objects[2])
            realm.delete(objects[3])
            realm.delete(objects[4])
        }
        
        waitForExpectations(timeout: 1000.1, handler: { _ in disposable.dispose() })
    }

}
