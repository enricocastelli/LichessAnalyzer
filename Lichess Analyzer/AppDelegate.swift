//
//  AppDelegate.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var clientID = "T0qPkzZHRnGRvhPe"
    var secret = "mclxfoRvA59n4U8AFOowMV09Z4GXcE3w"

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let home = HomeVC()
        let nav = UINavigationController(rootViewController: home)
        nav.isNavigationBarHidden = true
        window?.rootViewController = nav
        FirebaseApp.configure()
        UserData.shared.updateOpenings()
        return true
    }


}

