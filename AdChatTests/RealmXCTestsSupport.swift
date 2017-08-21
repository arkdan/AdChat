//
//  RealmXCTestsSupport.swift
//  AdChat
//
//  Created by mac on 8/19/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import XCTest
import RealmSwift
@testable import AdChat


class TestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        AdChat.makeRealm = testRealm
    }
}

private var databaseVersion: UInt64 {
    return 1
}

extension Realm.Configuration {
    static var testConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration.defaultConfiguration
        var url = configuration.fileURL!
        let lastPathComponent = "test" + url.lastPathComponent
        url = url.deletingLastPathComponent().appendingPathComponent(lastPathComponent)
        configuration.fileURL = url
        return configuration
    }()
}

extension Realm {

    final class func migrate(to version: UInt64 = databaseVersion) {
        Configuration.testConfiguration.schemaVersion = version
    }
}

func testRealm() -> Realm {
    return try! Realm(configuration: .testConfiguration)
}
