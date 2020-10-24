//
//  HomeVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import UIKit

class HomeVC: UIViewController, GamesServiceProvider, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var gameTypeControl: UISegmentedControl!
    @IBOutlet weak var ratedSwitch: UISwitch!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var progressView: UIProgressView!


    var maxNums = [50, 100, 500, 1000, 2000]
    var color = Color.white
    var gameType = GameType.all
    var maxNum: Int? = 50
    var username: String {
        return nameTextField.text ?? ""
    }
    var callInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        whiteButton.layer.borderColor = UIColor.black.cgColor
        blackButton.layer.borderColor = UIColor.black.cgColor
        setColorSelected(color)
        setGameTypeControl()

        // test
        nameTextField.text = "santapolenta"
        nameTextField.delegate = self
        nameTextField.returnKeyType = .go
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.alpha = callInProgress ? 1 : 0
    }

    private func setGameTypeControl() {
        gameTypeControl.setTitle("Ultrabullet", forSegmentAt: 0)
        gameTypeControl.setTitle("Bullet", forSegmentAt: 1)
        gameTypeControl.setTitle("Blitz", forSegmentAt: 2)
        gameTypeControl.setTitle("All", forSegmentAt: 3)
        gameTypeControl.selectedSegmentIndex = 3
    }

    @IBAction func whiteTapped() {
        self.color = .white
        setColorSelected(color)
    }

    @IBAction func blackTapped() {
        self.color = .black
        setColorSelected(color)
    }

    @IBAction func selectedType() {
        switch gameTypeControl.selectedSegmentIndex {
        case 0: gameType = .ultrabullet
        case 1: gameType = .bullet
        case 2: gameType = .blitz
        default: gameType = .all
        }
    }

    private func setColorSelected(_ color: Color) {
        whiteButton.layer.borderWidth = color == .white ? 2 : 0
        blackButton.layer.borderWidth = color == .black ? 2 : 0
    }

    @IBAction func analyze() {
        showLoading()
        callInProgress = true
        UserData.shared.name = username
        UserData.shared.search = (color, gameType)
        getGames(user: username,
                 max: maxNum,
                 color: color,
                 type: gameType,
                 rated: ratedSwitch.isOn) { (games) in
            self.callInProgress = false
            guard let games = games else { return }
            self.navigationController?.pushViewController(ResultVC(games), animated: true)
        } failure: { (error) in
            self.loadingView.alpha = 0
        }
    }

    private func showLoading() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        let _ = Timer.scheduledTimer(withTimeInterval: getTimeProgress(), repeats: true) { (timer) in
            guard self.callInProgress else {
                timer.invalidate()
                self.progressView.progress = 0.05
                return
            }
            self.progressView.progress += self.progressView.progress > 0.95 ? 0 : 0.1
        }
    }

    private func getTimeProgress() -> Double {
        switch maxNum {
        case 50: return 0.5
        case 100: return 1
        case 500: return 1.8
        case 1000: return 2.0
        case 2000: return 3.0
        default: return 2
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension HomeVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "50"
        case 1: return "100"
        case 2: return "500"
        case 3: return "1000"
        case 4: return "2000"
        default: return "All"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        maxNum = row == 5 ? nil : maxNums[row]
        UIView.animate(withDuration: 0.2) {
            self.warningLabel.alpha = row > 2 ? 1 : 0
        }
    }
}
