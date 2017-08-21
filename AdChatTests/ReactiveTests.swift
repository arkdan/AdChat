//
//  ReactiveTests.swift
//  AdChat
//
//  Created by mac on 8/11/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import XCTest
import Nimble
@testable import AdChat

import ReactiveSwift
import ReactiveCocoa
import Result
import Extensions

class ReactiveTests: TestCase {

    func testButtonPing() {
        let exp = expectation(description: #function)

        let button = UIButton(type: .custom)

        var touchUpCount = 0
        button.reactive.ping(on: .touchUpInside).observeValues {
            touchUpCount += 1
        }

        DispatchQueue.main.delayed(0.2) {
            expect(touchUpCount) == 4
            exp.fulfill()
        }

        button.sendActions(for: .touchUpInside)

        button.sendActions(for: .touchDown)
        button.sendActions(for: .touchDragExit)
        button.sendActions(for: .touchDragEnter)
        button.sendActions(for: .touchUpOutside)

        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 1000.1, handler: nil)
    }
}
