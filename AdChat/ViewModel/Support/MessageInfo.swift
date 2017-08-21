//
//  MessageInfo.swift
//  AdChat
//
//  Created by mac on 8/12/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import Foundation

struct MessageInfo {
    let author: String
    let content: MessageContent
    let date: Date

    var dateString: String {
        let dateFormatter: DateFormatter = Calendar.current.isDateInToday(date) ? .time : .day
        return dateFormatter.string(from: date)
    }
}

fileprivate extension DateFormatter {

    fileprivate static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()

    fileprivate static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

extension MessageInfo {
    init(_ message: Message) {
        self.author = message.author.name
        self.content = message.content
        self.date = message.timestamp
    }
}
