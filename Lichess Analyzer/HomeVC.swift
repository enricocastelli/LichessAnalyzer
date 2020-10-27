//
//  HomeVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit
import SafariServices

class HomeVC: UIViewController, ServiceProvider, UITextFieldDelegate, StoreProvider, TextPresenter {

    @IBOutlet weak var visibleView: UIView!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var filterLabel: UILabel!

    var gameTypeControl: UISegmentedControl!


    var maxNums = [100, 500]
    var gameTypes: [GameType] = [.bullet, .blitz, .rapid, .all]
    var color = Color.white
    var gameType = GameType.all
    var maxNum: Int = 50

    var callInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = false
        addText("Hello \(UserData.shared.account?.username ?? "Stranger")", delay: 0.4, duration: 0.8, position: CGPoint(x: 40, y: 16), lineWidth: 1, font: Font.with(.hairline, 32), color: UIColor.darkGray.withAlphaComponent(0.8), inView: textContainerView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.alpha = callInProgress ? 1 : 0
        updatelabel()
    }

    private func updatelabel() {
        filterLabel.attributedText = UserData.shared.search.attrString
    }

    @IBAction func analyze() {
        showLoading()
        callInProgress = true
        getGames() { (games) in
            self.callInProgress = false
            guard let games = games else { return }
            self.navigationController?.pushViewController(ResultVC(games), animated: true)
        } failure: { (error) in
            self.loadingView.alpha = 0
        }
    }

    private func getTimeProgress() -> Double? {
        guard let estim = UserData.shared.estimatedDownloadTime() else { return nil }
        return estim/8
    }

    private func showLoading() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        let hasProgress = getTimeProgress() != nil
        let _ = Timer.scheduledTimer(withTimeInterval: getTimeProgress() ?? 0.1, repeats: true) { (timer) in
            guard self.callInProgress else {
                timer.invalidate()
                self.progressView.progress = 0.05
                return
            }
            if self.progressView.progress > 0.95 {
                self.progressView.progress = hasProgress ? 0.95 : 0
            } else {
                self.progressView.progress += 0.1
            }
        }
    }

    @IBAction func filterTapped() {
        let filter = FilterVC()
        filter.onSelect = updatelabel
        filter.modalPresentationStyle = .overCurrentContext
        self.present(filter, animated: true, completion: nil)
    }
}

