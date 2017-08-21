//
//  ChatListViewController.swift
//  Contacts
//
//  Created by ark dan on 22/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

final class ChatListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noConversationsLabel: UILabel!

    var viewModel: ChatListViewModel!

    fileprivate var tableViewManager: SignalTableViewManager<ChatListCellViewModel, ChatListCell>?


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"

        navigationController?.tabBarItem.image = UIImage(named: "messages")

        noConversationsLabel.reactive.isHidden <~ viewModel.outputs.isEmpty.map { !$0 }

        tableViewManager = SignalTableViewManager(producer: viewModel.outputs.cells,
                                                  tableView: tableView,
                                                  cellMapping: { _ in ChatListCell.self })

        tableViewManager?.cellHeight = 72
        tableViewManager?.canEdit = { _ in return true }
        tableViewManager?.delete = { cellViewModel in
            cellViewModel.deleteConversation.ping()
            self.tableView.reloadData()
        }

        tableViewManager?.rowActionSignal
            .observe(on: UIScheduler())
            .observeValues { (cellViewModel, indexPath) in
                self.viewModel.startConversation(participants: cellViewModel.usersExceptMe)
                self.tableView.deselectRow(at: indexPath, animated: true)
        }

        automaticallyAdjustsScrollViewInsets = false
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false
    }
}
