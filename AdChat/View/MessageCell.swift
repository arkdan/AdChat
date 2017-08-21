//
//  MessageCell.swift
//  AdChat
//
//  Created by mac on 8/14/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import UIKit
import UIKitExtensions

class MessageCell: UICollectionViewCell, ViewModelConfiguredCell {

    @IBOutlet fileprivate weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var contentHeightConstraint: NSLayoutConstraint!

    func configure(with viewModel: MessageCellViewModel) {
        let size = viewModel.contentSize
        contentWidthConstraint.constant = size.width
        contentHeightConstraint.constant = size.height
    }

    class var identifier: String {
        return "MessageCell"
    }
}

class TextMessageCell: MessageCell {

    @IBOutlet fileprivate weak var messageLabel: InsetsLabel! {
        willSet {
            newValue.makeRound(15)
            newValue.insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            TextRect.messages.font = newValue.font
        }
    }

    override func configure(with viewModel: MessageCellViewModel) {
        super.configure(with: viewModel)

        guard case let .text(text) = viewModel.messageInfo.content else {
            fatalError("incorrect message content in cell")
        }
        messageLabel.text = text
    }
}

class ImageMessageCell: MessageCell {

    @IBOutlet fileprivate weak var imageView: UIImageView! {
        willSet {
            newValue.makeRound(10)
        }
    }

    override func configure(with viewModel: MessageCellViewModel) {
        super.configure(with: viewModel)

        guard case let .image(data) = viewModel.messageInfo.content else {
            fatalError("incorrect message content in cell")
        }
        imageView.image = UIImage(data: data)
    }
}

final class OwnTextMessageCell: TextMessageCell {

    override class var identifier: String {
        return "OwnTextMessageCell"
    }
}

final class OwnImageMessageCell: ImageMessageCell {

    override class var identifier: String {
        return "OwnImageMessageCell"
    }
}

final class PartnersTextMessageCell: TextMessageCell {
    @IBOutlet private weak var avatarImageView: UIImageView! {
        willSet {
            newValue.makeRound()
        }
    }

    override func configure(with viewModel: MessageCellViewModel) {
        super.configure(with: viewModel)
        avatarImageView.image = viewModel.avatar.flatMap { UIImage(data: $0) }
    }

    override class var identifier: String {
        return "PartnersTextMessageCell"
    }
}

final class PartnersImageMessageCell: ImageMessageCell {
    @IBOutlet private weak var avatarImageView: UIImageView! {
        willSet {
            newValue.makeRound()
        }
    }

    override func configure(with viewModel: MessageCellViewModel) {
        super.configure(with: viewModel)
        avatarImageView.image = viewModel.avatar.flatMap { UIImage(data: $0) }
    }


    override class var identifier: String {
        return "PartnersImageMessageCell"
    }
}
