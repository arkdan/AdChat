//
//  Extension.swift
//  AdChat
//
//  Created by mac on 8/21/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation

extension Array {
    public func appending(_ newElement: Element) -> [Element] {
        var copy = self
        copy.append(newElement)
        return copy
    }
    public func appending<S>(contentsOf newElements: S) -> [Element] where S : Sequence, S.Iterator.Element == Element {
        var copy = self
        copy.append(contentsOf: newElements)
        return copy
    }
}
