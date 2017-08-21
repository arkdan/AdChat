//
//  UserListCell.swift
//  Contacts
//
//  Created by mac on 8/8/17.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import UIKitExtensions
import ReactiveSwift
import ReactiveCocoa

final class UserListCell: UITableViewCell, ViewModelConfiguredCell {

    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var avatarImageView: UIImageView! {
        willSet {
            newValue.makeRound()
        }
    }

    func configure(with viewModel: UserListCellViewModel) {
        userLabel.text = viewModel.outputs.username
        avatarImageView.image = UIImage(data: viewModel.outputs.userImage)

        button.reactive.ping(on: .touchUpInside)
            .take(until: self.reactive.prepareForReuse)
            .observeValues {
            viewModel.inputs.loadChatProperty.value = ()
        }
    }

    static var identifier: String {
        return "UserListCell"
    }
}
