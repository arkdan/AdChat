//
//  ChatListCell.swift
//  AdChat
//
//  Created by mac on 8/11/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import UIKit
import ReactiveSwift

final class ChatListCell: UITableViewCell, ViewModelConfiguredCell {

    @IBOutlet private weak var lastMessageLabel: UILabel!
    @IBOutlet private weak var lastMessageImageView: UIImageView!
    @IBOutlet private weak var participantsLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var messagesCountLabel: UILabel! {
        willSet {
            newValue.makeRound()
        }
    }
    @IBOutlet private weak var avatarImageView: UIImageView! {
        willSet {
            newValue.makeRound()
        }
    }

    func configure(with viewModel: ChatListCellViewModel) {

        participantsLabel.text = viewModel.outputs.usersExceptMe.reduce("") { $0 + $1.name }
        let imageData = viewModel.outputs.usersExceptMe.first?.avatar.imageData
        avatarImageView.image = imageData.flatMap { UIImage(data: $0) }

        viewModel.outputs.lastMessage
            .take(until: self.reactive.prepareForReuse)
            .startWithValues { messageInfo in

                guard let messageInfo = messageInfo else {
                    self.lastMessageLabel.text = nil
                    self.lastMessageImageView.image = nil
                    self.dateLabel.text = nil
                    return
                }

                switch messageInfo.content {
                case .text(let text):
                    self.lastMessageLabel.text = text
                case .image(let data):
                    self.lastMessageImageView.image = UIImage(data: data)
                }
                self.lastMessageLabel.isHidden = !messageInfo.content.isText
                self.lastMessageImageView.isHidden = messageInfo.content.isText
                self.dateLabel.text = messageInfo.dateString
        }
        viewModel.outputs.messagesCount
            .take(until: self.reactive.prepareForReuse)
            .startWithValues { count in
//                self.messagesCountLabel.isHidden = count == 0
                self.messagesCountLabel.text = "  \(count)  " // spaces for the round edges
        }
    }

    static var identifier: String {
        return "ChatListCell"
    }
}
