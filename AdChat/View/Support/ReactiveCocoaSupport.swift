//
//  ReactiveCocoaSupport.swift
//  Contacts
//
//  Created by ark dan on 26/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit

import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

extension MutableProperty where Value == Void {
    func ping() {
        self.value = ()
    }
}

extension Reactive where Base: UIControl {
    func ping(on controlEvents: UIControlEvents) -> ReactiveSwift.Signal<Void, NoError> {
        return mapControlEvents(controlEvents, { (_) -> Void in return () })
    }
}
