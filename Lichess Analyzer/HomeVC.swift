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

    var gameTypeControl: UISegmentedControl!
    var gameTypes: [GameType] = [.bullet, .blitz, .rapid, .all]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = false
        addText("Hello \(UserData.shared.account?.username ?? "Stranger")", delay: 0.4, duration: 0.8, position: CGPoint(x: 40, y: 16), lineWidth: 1, font: Font.with(.hairline, 32), color: UIColor.darkGray.withAlphaComponent(0.8), inView: textContainerView)
        setGameTypeControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.alpha = 0
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
        if gameTypeControl.selectedSegmentIndex == 2 {
            deleteGames {
                print("🐴 deleted")
            } failure: { (_) in}
        }
        UserData.shared.search.gameType = gameTypes[gameTypeControl.selectedSegmentIndex]
        updateLabel()
    }

    @IBAction func analyze() {
        showLoading()
        getStoredGames { (games) in
            print("🐴 got \(games.count) stored games")
            UserData.shared.games = games
            self.storeLastDate(games.last?.date ?? "")
            self.getAll(since: games.last?.date.toDate("yyyy-MM-dd'H'HH-mmm-ss")?.addingTimeInterval(1), until: nil) {
                self.openResult()
            }
        } failure: { (error) in
            print("🐴 no stored games found")
            self.showLoading()
            self.getExample {}
        }
    }

    private func getAll(since: Date?, until: Date?, completion: @escaping () -> ()) {
        print("🐴 getting games from \(since) to \(until)")
        self.getGames(nil, sinceDate: since?.millisecondsSince1970, untilDate: until?.millisecondsSince1970) { (games) in
            guard let games = games, !games.isEmpty else {
                print("🐴 no new games")
                completion()
                return }
            print("🐴 received \(games.count) games")
            UserData.shared.games.append(contentsOf: games)
            print("🐴 now userdata has \(UserData.shared.games.count) games")
            self.storeGames(games) {
                NotificationCenter.default.post(Notification(name: .CallFinished))
                completion()
            } failure: { (err) in }
        } failure: { (error) in }
    }

    private func getExample(_ completion: @escaping () -> ()) {
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
}

