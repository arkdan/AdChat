//
//  AppCoordinator.swift
//  Contacts
//
//  Created by ark dan on 22/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import Extensions
import UIKitExtensions
import ReactiveSwift
import Result


final class AppCoordinator {

    let storyboard: UIStoryboard

    private let tabBarController: UITabBarController

    init(tabBarController: UITabBarController, storyboard: UIStoryboard) {
        self.tabBarController = tabBarController
        self.storyboard = storyboard
    }

    func start() {

        tabBarController.userListViewController().viewModel.outputs.startChat
            .observe(on: UIScheduler())
            .observeValues { self.loadChat($0) }

        let chatListViewModel = ChatListViewModel()

        chatListViewModel.loadChat
            .observe(on: UIScheduler())
            .observeValues { self.loadChat($0) }

        tabBarController.chatListViewController().viewModel = chatListViewModel
        let _ = tabBarController.chatListViewController().view

        Session.shared.currentUser.producer.startWithValues { user in
            if let user = user {
                self.login(user: user)
            } else {
                self.showLogin()
            }
        }
    }

    func login(user: User) {
        tabBarController.dismiss(animated: true, completion: nil)
    }

    func showLogin(animated: Bool = true) {
        let loginViewModel = LoginViewModel()
        let loginVC = storyboard.instantiateViewController(LoginViewController.self)
        loginVC.viewModel = loginViewModel

        loginVC.modalPresentationStyle = .overCurrentContext
        tabBarController.present(loginVC, animated: animated, completion: nil)
    }

    func loadChat(_ chat: ConversationViewModel) {
        let tab: UITabBarController.Tab = .chats
        let nav = tabBarController.navigationController(forTab: tab)

        tabBarController.selectedIndex = tab.rawValue
        nav.popToRootViewController(animated: false)

        let chatVC = storyboard.instantiateViewController(ChatViewController.self)
        chatVC.viewModel = chat

        nav.pushViewController(chatVC, animated: true)
    }
}

private extension UITabBarController {
    enum Tab: Int {
        case userList
        case chats
    }

    func navigationController(forTab tab: Tab) -> UINavigationController {
        return viewControllers?[tab.rawValue] as! UINavigationController
    }

    func userListViewController() -> UserListViewController {
        return navigationController(forTab: .userList).viewControllers[0] as! UserListViewController
    }

    func chatListViewController() -> ChatListViewController {
        return navigationController(forTab: .chats).viewControllers[0] as! ChatListViewController
    }

    func setViewController(_ viewController: UIViewController, at index: Int) {
        guard var all = viewControllers else {
            return
        }
        all[index] = viewController
        setViewControllers(all, animated: false)
    }
}
