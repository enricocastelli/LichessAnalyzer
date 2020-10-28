//
//  AppDelegate.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit
import Firebase
import OAuthSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let nav = UINavigationController(rootViewController: WelcomeVC())
        nav.isNavigationBarHidden = true
        window?.rootViewController = nav
        FirebaseApp.configure()
        UserData.shared.updateOpenings()
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return true }
        handleDeepLinkUrl(url)
        return true
    }

    func handleDeepLinkUrl(_ url: URL) {
        OAuthSwift.handle(url: url)
    }

    // remove gameOpening/complete opening models ?
    // filters in result screen
    // known openings should be basic openings with explanation
    // search specific set of moves
    // download all games and store them, then next times update from a specific date
}

