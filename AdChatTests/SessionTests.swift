//
//  SessionTests.swift
//  AdChat
//
//  Created by ark dan on 26/07/2017.
//  Copyright © 2017 ark dan. All rights reserved.
//

import XCTest
import Nimble
@testable import AdChat

import ReactiveSwift
import Result

class SessionTests: TestCase {
    
    func testCurrentUser() {

        let exp = expectation(description: #function)

        var count = 0

        let name1 = randomUsername()
        let name2 = randomUsername()

        let session = Session.shared

        session.currentUser.value = nil

        session.currentUser.producer.startWithValues { user in
            switch count {
            case 0:
                expect(session.currentUser.value).to(beNil())
            case 1:
                expect(session.currentUser.value?.name) == name1
            case 2:
                expect(session.currentUser.value?.name) == name2
                exp.fulfill()
            default:
                fail()
            }
            count += 1
        }

        session.currentUser.value = User(name: name1)
        session.currentUser.value = User(name: name2)

        waitForExpectations(timeout: 1000.1, handler: nil)
    }
    
}
