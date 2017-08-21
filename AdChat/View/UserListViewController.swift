//
//  UserListViewController.swift
//  Contacts
//
//  Created by ark dan on 21/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result


final class UserListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private(set) lazy var viewModel = UserListViewModel(user: nil)

    fileprivate var tableViewManager: SignalTableViewManager<UserListCellViewModel, UserListCell>?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Users"

        viewModel.outputs.currentUserNameImage.startWithValues { (name, imageData) in

            let image = imageData.flatMap { UIImage(data: $0)?.scaled(w: 34, h: 34) }
            let imageItem = UIBarButtonItem(customView: UIImageView(image: image).rounded())

            let nameItem = UIBarButtonItem(title: name, style: .plain, target: nil, action: nil)

            let logoutItem = UIBarButtonItem(image: name == nil ? nil : #imageLiteral(resourceName: "logout"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(UserListViewController.onLogout(_:)))

            self.navigationItem.setLeftBarButtonItems([imageItem, nameItem], animated: false)
            self.navigationItem.setRightBarButton(logoutItem, animated: false)
        }

        navigationController?.tabBarItem.image = #imageLiteral(resourceName: "contacts")

        tableViewManager = SignalTableViewManager(producer: viewModel.outputs.cells,
                                                  tableView: tableView,
                                                  cellMapping: { _ in UserListCell.self })
        tableViewManager?.cellHeight = 64

        tableViewManager?.canEdit = { _ in true }
        tableViewManager?.rowActionSignal.observeValues { (_, indexPath) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }

        automaticallyAdjustsScrollViewInsets = false
        tableView.tableFooterView = UIView()
    }

    @objc private func onLogout(_ sender: UIBarButtonItem) {
        viewModel.inputs.exit()
    }
}
