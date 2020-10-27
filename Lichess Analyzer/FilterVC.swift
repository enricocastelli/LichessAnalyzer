//
//  FilterVIC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 27/10/2020.
//

import UIKit

class FilterVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var gameTypeContainerView : UIView!
    @IBOutlet weak var maxNumContainerView : UIView!
    @IBOutlet weak var ratedSwitch: UISwitch!
    @IBOutlet weak var expiredSwitch: UISwitch!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!

    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var blurView: UIView!


    var gameTypeControl: UISegmentedControl!
    var maxTypeControl: UISegmentedControl!

    var maxNums = [100, 500]
    var gameTypes: [GameType] = [.bullet, .blitz, .rapid, .all]
    var timings: [Timing] = [.accountCreation, .beginningYear, .beginningMonth, ._20Days, ._7Days, .today]

    var onSelect: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        whiteButton.layer.borderColor = UIColor.black.cgColor
        blackButton.layer.borderColor = UIColor.black.cgColor
        setColorSelected(UserData.shared.search.color)
        setGameTypeControl()
        setMaxNums()
        setSlider()
        ratedSwitch.isOn = UserData.shared.search.rated
        expiredSwitch.isOn = UserData.shared.search.nonExpired
    }

    private func setGameTypeControl() {
        guard let account = UserData.shared.account else { return }
        gameTypes = account.perfsAvailable()
        gameTypeControl = UISegmentedControl(items: gameTypes.map({$0.rawValue.uppercased()}))
        gameTypeContainerView.addContentView(gameTypeControl)
        gameTypeControl.addTarget(self, action: #selector(selectedType), for: .valueChanged)
        guard let index = gameTypes.firstIndex(of: UserData.shared.search.gameType) else { return }
        gameTypeControl.selectedSegmentIndex = index
        UserData.shared.search.gameType = gameTypes[gameTypeControl.selectedSegmentIndex]
        updateTimeLabel()
    }

    private func setMaxNums() {
        guard UserData.shared.isLoggedIn(), let totalGame = gamesForSelectedType() else { return }
        switch totalGame {
        case let x where x < 100: maxNums = [totalGame]
        case let x where x > 100 && x < 500: maxNums = [10, 100, totalGame]
        case let x where x > 500 && x < 1000: maxNums = [100, 500, totalGame]
        case let x where x > 1000 && x < 5000: maxNums = [200, 500, 1000, totalGame]
        case let x where x > 5000 && x < 10000: maxNums = [100, 500, 1000, 5000, totalGame]
        case let x where x > 10000 && x < 15000: maxNums = [100, 500, 1000, 7000, totalGame]
        default: maxNums = [100, 500, 1000, 10000, totalGame]
        }
        if maxTypeControl != nil {
            maxTypeControl.removeFromSuperview()
        }
        maxTypeControl = UISegmentedControl(items: maxNums.map({$0.description}))
        maxNumContainerView.addContentView(maxTypeControl)
        maxTypeControl.addTarget(self, action: #selector(selectedMaxNum), for: .valueChanged)
        let index = maxNums.firstIndex(of: UserData.shared.search.max ?? -1) ?? UISegmentedControl.noSegment
        maxTypeControl.selectedSegmentIndex = index
        updateTimeLabel()
    }

    private func setSlider() {
        if let since = UserData.shared.search.since {
            switch since {
            case .accountCreation: timeSlider.setValue(0, animated: false)
            case .beginningYear: timeSlider.setValue(0.2, animated: false)
            case .beginningMonth: timeSlider.setValue(0.4, animated: false)
            case ._20Days: timeSlider.setValue(0.6, animated: false)
            case ._7Days: timeSlider.setValue(0.8, animated: false)
            case .today: timeSlider.setValue(1, animated: false)
            }
            let index = timings.firstIndex(of: since) ?? 0
            timeLabel.text = timings[index].desc()
        } else {
            timeSlider.setValue(0, animated: false)
            timeLabel.text = ""
        }
    }

    private func gamesForSelectedType() -> Int? {
        return UserData.shared.account?.numberOfGamesForType(UserData.shared.search.gameType)
    }

    private func updateTimeLabel() {
        if let estim = estimatedDownloadTime() {
        warningLabel.text = "Estimated download time: \(Int(estim).secondsToMinutesSecondsString())"
        } else {
            warningLabel.text = ""
        }
    }

    private func estimatedDownloadTime() -> Double? {
        return UserData.shared.estimatedDownloadTime()
    }

    @IBAction func allTapped() {
        UserData.shared.search.color = .all
        setColorSelected(.all)
    }

    @IBAction func whiteTapped() {
        UserData.shared.search.color = .white
        setColorSelected(.white)
    }

    @IBAction func blackTapped() {
        UserData.shared.search.color = .black
        setColorSelected(.black)
    }

    @IBAction func ratedSwitchTapped() {
        UserData.shared.search.rated = ratedSwitch.isOn
    }

    @IBAction func expiredSwitchTapped() {
        UserData.shared.search.nonExpired = expiredSwitch.isOn
    }

    @IBAction func applyFilters() {
        onSelect?()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sliderChanged(_ sender: Any) {
        maxTypeControl.selectedSegmentIndex = UISegmentedControl.noSegment
        UserData.shared.search.max = nil
        var indexSelected = 0
        switch timeSlider.value {
        case let x where x == 0: indexSelected = 0
        case let x where x < 0.2: indexSelected = 1
        case let x where x < 0.4: indexSelected = 2
        case let x where x < 0.6: indexSelected = 3
        case let x where x < 0.8: indexSelected = 4
        default: indexSelected = 5
        }
        timeLabel.text = timings[indexSelected].desc()
        UserData.shared.search.since = timings[indexSelected]
    }

    @objc func selectedType() {
        UserData.shared.search.gameType = gameTypes[gameTypeControl.selectedSegmentIndex]
        updateTimeLabel()
        setMaxNums()
    }

    @objc func selectedMaxNum() {
        UserData.shared.search.max = maxNums[maxTypeControl.selectedSegmentIndex]
        updateTimeLabel()
    }

    private func setColorSelected(_ color: Color) {
        whiteButton.layer.borderWidth = color == .white ? 1.5 : 0
        blackButton.layer.borderWidth = color == .black ? 1.5 : 0
        allButton.layer.borderWidth = color == .all ? 1.5 : 0
    }

//    func dismiss() {
//        closeAnimation()
//    }

//    func expand() {
//        preAnimation()
//        UIView.animate(withDuration: 0.5, animations: {
//            self.blurView.alpha = 1
//            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
//            self.selectionView.transform = CGAffineTransform(scaleX: 1, y: 1)
//        }) { (_) in }
//        containerTopConstraint.constant = 0
//        bottomConstraint.constant = 20
//        layoutSizeContent()
//        updateLayoutAnimated(0.3)
//    }
//
//    private func preAnimation() {
//        blurView.alpha = 0
//        containerTopConstraint.constant = UIScreen.main.bounds.height
//        bottomConstraint.constant = -UIScreen.main.bounds.height
//        layoutSizeContent()
//        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 1)
//        selectionView.transform = CGAffineTransform(scaleX: 0.9, y: 1)
//        layoutIfNeeded()
//    }
//
//    private func layoutSizeContent() {
//        if let containerHeight = self.delegate?.calculatedContentSize() {
//            self.containerHeightConstraint.constant = containerHeight
//        }
//    }
//
//    private func closeAnimation() {
//        containerTopConstraint.constant = -5
//        bottomConstraint.constant = 25
//        UIView.animate(withDuration: 0.1, animations: {
//            self.view.layoutIfNeeded()
//        }) { (_) in
//            self.containerTopConstraint.constant = UIScreen.main.bounds.height
//            self.bottomConstraint.constant = -UIScreen.main.bounds.height
//            self.view.updateLayoutAnimated(0.2)
//        }
//        UIView.animate(withDuration: 0.4, animations: {
//            self.blurView.alpha = 0
//            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.1)
//            self.selectionView.transform = CGAffineTransform(scaleX: 0.7, y: 1.1)
//        }) { (_) in
//            self.removeFromSuperview()
//        }
//    }
}

