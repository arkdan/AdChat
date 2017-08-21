//
//  MessageContent.swift
//  AdChat
//
//  Created by mac on 8/20/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation

enum MessageContent {
    case text(String)
    case image(Data)

    var isText: Bool {
        switch self {
        case .text:
            return true
        case .image:
            return false
        }
    }
}

extension MessageContent: Equatable {
    static func ==(lhs: MessageContent, rhs: MessageContent) -> Bool {
        switch (lhs, rhs) {
        case (.text(let t1), .text(let t2)):
            return t1 == t2
        case (.image(let i1), .image(let i2)):
            return i1 == i2
        default:
            return false
        }
    }
}
