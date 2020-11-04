//
//  HomeVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit
import SafariServices
import WebKit

class HomeVC: UIViewController, ServiceProvider, UITextFieldDelegate, StoreProvider, TextPresenter {

    @IBOutlet weak var visibleView: UIView!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var controlContainerView: UIView!
    @IBOutlet weak var allLabel: UILabel!

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var gameTypeControl: UISegmentedControl!
    var gameTypes: [GameType] = [.bullet, .blitz, .rapid, .all]
    var callInProgress = false
    var isExample = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = false
        addText("Hello \(UserData.shared.account?.username ?? "Stranger")", delay: 0.4, duration: 0.8, position: CGPoint(x: 40, y: 16), lineWidth: 1, font: Font.with(.hairline, 32), color: UIColor.darkGray.withAlphaComponent(0.8), inView: textContainerView)
        setGameTypeControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.alpha = callInProgress ? 1 : 0
    }

    private func setGameTypeControl() {
        guard let account = UserData.shared.account else { return }
        gameTypes = account.perfsAvailable()
        gameTypeControl = UISegmentedControl(items: gameTypes.map({$0.rawValue.uppercased()}))
        controlContainerView.addContentView(gameTypeControl)
        gameTypeControl.addTarget(self, action: #selector(selectedType), for: .valueChanged)
        guard let index = gameTypes.firstIndex(of: UserData.shared.search.gameType) else { return }
        gameTypeControl.selectedSegmentIndex = index
        UserData.shared.search.gameType = gameTypes[gameTypeControl.selectedSegmentIndex]
        updateLabel()
        let font = [NSAttributedString.Key.font : Font.with(Style.light, 18)]
        gameTypeControl.setTitleTextAttributes(font, for: .normal)
    }

    func updateLabel() {
        guard let gamesNuber = UserData.shared.account?.numberOfGamesForType(UserData.shared.search.gameType) else { return }
        allLabel.changeText("\(gamesNuber.description) GAMES")
    }

    @objc func selectedType() {
        UserData.shared.search.gameType = gameTypes[gameTypeControl.selectedSegmentIndex]
        updateLabel()
    }


    func dataCheck() -> Bool {
        if U.shared.account?.numberOfGamesForType(U.shared.search.gameType) ?? 0 > 1000 {
            self.showAlert()
            return true
        } else {
            return false
        }
    }

    @IBAction func analyze(_ bypassDataCheck: Bool = false) {
        guard !callInProgress else { return }
        showLoading()
        getStoredGames(gameType: U.shared.search.gameType) { (games) in
            print("🐴 got \(games.count) stored games")
            UserData.shared.games = games
            self.storeLastDate(games.last?.date ?? "")
            self.getAll(since: games.last?.date.toDate("yyyy-MM-dd'H'HH-mmm-ss")?.addingTimeInterval(1), until: nil) {
                self.openResult()
            }
        } failure: { (error) in
            if !bypassDataCheck {
                if self.dataCheck() {
                    return
                }
            }
            print("🐴 no stored games found")
            self.showLoading()
            self.getExample {}
        }
    }

    @IBAction func openFeedback() {
        self.present(FeedbackVC(), animated: true, completion: nil)
    }

    private func getAll(since: Date?, until: Date?, completion: @escaping () -> ()) {
        print("🐴 getting games from \(since) to \(until)")
        callInProgress = true
        registerBackgroundTask()
        self.getGames(nil, sinceDate: since?.millisecondsSince1970, untilDate: until?.millisecondsSince1970) { (games) in
            self.callInProgress = false
            if self.backgroundTask != .invalid {
                self.endBackgroundTask()
            }
            guard let games = games, !games.isEmpty else {
                print("🐴 no new games")
                completion()
                return }
            print("🐴 received \(games.count) games")
            if !self.isExample {
                U.shared.games.append(contentsOf: games)
            } else {
                U.shared.games = games
            }
            print("🐴 now userdata has \(UserData.shared.games.count) games")
            self.storeGames(games, gameType: U.shared.search.gameType) {
                NotificationCenter.default.post(Notification(name: .CallFinished))
                completion()
            } failure: { (err) in
                self.callInProgress = false
                NotificationCenter.default.post(Notification(name: .CallFinished))
            }
        } failure: { (error) in
            self.callInProgress = false
            NotificationCenter.default.post(Notification(name: .CallFinished))
        }
    }

    private func getExample(_ completion: @escaping () -> ()) {
        isExample = true
        let _ = FloatingButtonController()
        self.getGames(100) { (games) in
            guard let games = games else { return }
            UserData.shared.games = games
            print("🐴 now userdata has \(games.count) games")
            self.openResult()
            self.getAll(since: nil, until: nil) {}
            completion()
        } failure: { (error) in
            self.loadingView.alpha = 0
        }
    }

    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }

    func endBackgroundTask() {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }

    private func openResult() {
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(ResultVC(), animated: true)
        }
    }
    
    private func showLoading() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Hi!",
                                      message: "This amount of games requires some time to download the first time, so in the mean time we will show you the last 100 you played, to get familiar with the app 🤓", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.analyze(true)
        }
        alert.addAction(firstAction)

        let secondAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.loadingView.alpha = 0
        }
        alert.addAction(secondAction)
        self.present(alert, animated: true, completion: nil)
    }
}

