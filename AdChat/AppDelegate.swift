//
//  AppDelegate.swift
//  AdChat
//
//  Created by ark dan on 11/07/2017.
//  Copyright © 2017 ark dan. All rights reserved.
//

import UIKit
import UIKitExtensions
import Extensions
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private(set) lazy var appCoordinator: AppCoordinator = {
        let tabBar = self.window?.rootViewController as! UITabBarController
        return AppCoordinator(tabBarController: tabBar, storyboard: .main)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if !UserDefaults.standard.bool(forKey: "testDBCopied") {
            copyTestDatabase()
            UserDefaults.standard.set(true, forKey: "testDBCopied")
        }

        Realm.migrate()
        let _ = Session.shared

        // workaround to schedule vc presentation after root VC is loaded
        delay(0.1, queue: .main) {
            self.appCoordinator.start()
        }

        return true
    }
}

private func copyTestDatabase() {
    let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
    let testDBURL = Bundle.main.url(forResource: "default", withExtension: "realm")!
    try! FileManager.default.copyItem(at: testDBURL, to: realmURL)
}


