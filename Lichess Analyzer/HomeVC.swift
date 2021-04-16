//
//  HomeVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit
import SafariServices
import WebKit

class HomeVC: UIViewController, ServiceProvider, StoreProvider, TextPresenter, KeyboardProvider {

    @IBOutlet weak var visibleView: UIView!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var typeStackView: UIStackView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var playerField: UITextField!
    @IBOutlet weak var SearchButton: UIButton!

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var gameTypes: [GameType] = [.bullet, .blitz, .rapid, .classical, .all]
    var callInProgress = false
    var isExample = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addText("Hello \(UserData.shared.account?.username ?? "Stranger")", delay: 0.4, duration: 0.8, position: CGPoint(x: 40, y: 16), lineWidth: 1, font: Font.with(.hairline, 32), color: UIColor.darkGray.withAlphaComponent(0.8), inView: textContainerView)
        playerField.delegate = self
        emptyGamesCheck()
        addKeyboardObserver()
    }

    deinit {
        removeKeyboardObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGameTypeControl()
        (navigationController as? Navigation)?.canSwipe = false
    }

    private func emptyGamesCheck() {
        guard let account = UserData.shared.account else { return }
        var totalGames = 0
        for type in gameTypes {
            totalGames += account.numberOfGamesForType(type) ?? 0
        }
        if totalGames == 0 {
            showNoGamesAlert()
        }
    }

    private func setGameTypeControl() {
        guard let account = UserData.shared.account else { return }
        gameTypes = account.perfsAvailable()
        updateLabel()
        guard typeStackView.subviews.isEmpty else { return }
        for type in gameTypes {
            let button = UIButton()
            button.setSelfConstraint(constraint: .width, constant: 40)
            button.setRatioConstraint()
            button.setImage(UIImage(named: type.rawValue), for: .normal)
            button.tag = type.intValue()
            button.tintColor = type == U.shared.search.gameType ? .baseColor : .grayColor
            button.addTarget(self, action: #selector(selectedType(_:)), for: .touchUpInside)
            typeStackView.addArrangedSubview(button)
        }
    }

    func updateLabel() {
        guard let gamesNuber = UserData.shared.account?.numberOfGamesForType(UserData.shared.search.gameType) else { return }
        allLabel.changeText("\(gamesNuber.description) GAMES")
        updateStatus()
        typeLabel.changeText(UserData.shared.search.gameType.rawValue.uppercased())
    }

    func updateStatus() {
        guard let account = UserData.shared.account else { return }
        let nStoredGames = self.hasStoredGames(gameType: U.shared.search.gameType)
        guard nStoredGames != 0 else {
            statusImageView.image = UIImage(systemName: "xmark.icloud.fill")
            statusImageView.tintColor = UIColor.grayColor
            newLabel.text = ""
            return
        }
        let nAccountGames = account.numberOfGamesForType(U.shared.search.gameType) ?? 0
        if nStoredGames < nAccountGames {
            statusImageView.image = UIImage(systemName: "arrow.counterclockwise.icloud.fill")
            statusImageView.tintColor = UIColor.baseColor
            newLabel.text = "+\(((nAccountGames) - nStoredGames).description)"
        } else {
            statusImageView.image = UIImage(systemName: "checkmark.icloud.fill")
            statusImageView.tintColor = UIColor.greenColor
            newLabel.text = ""
        }
    }

    @objc func selectedType(_ button: UIButton) {
        UserData.shared.search.gameType = GameType.extract(button.tag)
        updateLabel()
        for button in typeStackView.subviews {
            button.tintColor = UIColor.grayColor
        }
        button.tintColor = UIColor.baseColor
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
        playerField.resignFirstResponder()
        U.shared.searchName = U.shared.account?.username ?? ""
        showLoadingAnimation()
        getStoredGames(gameType: U.shared.search.gameType) { (games) in
            print("🐴 got \(games.count) stored games")
            UserData.shared.games = games
            self.storeLastDate(games.last?.date ?? "")
            self.getAll(since: games.last?.date.toDate("yyyy-MM-dd'H'HH-mmm-ss")?.addingTimeInterval(1), until: nil) {
                // result will call hideLoading
                self.openResult()
            }
        } failure: { (error) in
            print("🐴 no stored games found")
            if !bypassDataCheck {
                if self.dataCheck() {
                    self.hideLoadingAnimation()
                    return
                }
            }
            if UserData.shared.account?.numberOfGamesForType(U.shared.search.gameType) ?? 0 > 100 {
                self.getExample {}
            } else {
                self.getAll(since: nil, until: nil) {
                    self.openResult()
                }
            }
        }
    }

    @IBAction func openFeedback() {
        playerField.resignFirstResponder()
        self.present(FeedbackVC(), animated: true, completion: nil)
    }

    func openSuggestion() {
        (self.navigationController as? Navigation)?.push(SuggestionVC())
    }

    @IBAction func searchTapped() {
        guard let text = playerField.text, !text.isEmpty else { return }
        guard text != U.shared.account?.username else {
            showMeAlert()
            return
        }
        playerField.resignFirstResponder()
        showLoadingAnimation()
        U.shared.searchName = text
        U.shared.filters = Filter(sorting: .weakest, color: .blackAndWhite, termination: .allTermination, timing: .accountCreation)
        self.getGames(500, type: .all) { games in
            guard let games = games, !games.isEmpty else {
                self.showErrorAlert()
                self.hideLoadingAnimation()
                return }
            U.shared.games = games
            self.openSuggestion()
        } failure: { (error) in
            self.showErrorAlert()
            self.hideLoadingAnimation()
        }
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
                self.hideLoadingAnimation()
                self.callInProgress = false
                NotificationCenter.default.post(Notification(name: .CallFinished))
            }
        } failure: { (error) in
            self.hideLoadingAnimation()
            self.callInProgress = false
            NotificationCenter.default.post(Notification(name: .CallFinished))
        }
    }

    private func getExample(_ completion: @escaping () -> ()) {
        isExample = true
        let _ = FloatingButtonController()
        self.getGames(100) { (games) in
            self.hideLoadingAnimation()
            guard let games = games else { return }
            UserData.shared.games = games
            print("🐴 now userdata has \(games.count) games")
            self.openResult()
            self.getAll(since: nil, until: nil) {}
            completion()
        } failure: { (error) in
            self.hideLoadingAnimation()
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
            (self.navigationController as? Navigation)?.push(ResultVC())
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
            self.hideLoadingAnimation()
        }
        alert.addAction(secondAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func showMeAlert() {
        let alert = UIAlertController(title: "Hey!",
                                      message: "Are you searching yourself? 🤔", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Ops", style: .default) { (_) in }
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func showErrorAlert() {
        let alert = UIAlertController(title: "Ops",
                                      message: "We couldn't find anyone with this username. Or perhaps this player doesn't have enough games played.", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func showNoGamesAlert() {
        let alert = UIAlertController(title: "Ops",
                                      message: "Seems like you don't have games played on lichess. First play some games, then come back for the analysis.", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
    }


    func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height/2)
            }
        }
    }

    func keyboardWillHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform.identity
        }
    }


}

extension HomeVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
