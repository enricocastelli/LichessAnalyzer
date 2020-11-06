//
//  WelcomeVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 26/10/2020.
//

import UIKit

class WelcomeVC: UIViewController, ServiceProvider, StoreProvider {

    @IBOutlet weak var lichessButton: UIButton!
    @IBOutlet weak var anonimousButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
//        deleteRefreshToken()
        setupButtons()
        if let token = getRefreshToken() {
            Auth().renewToken(token) {
                self.getAccount { (account) in
                    self.onAccountRetrieved(account)
                } failure: { (error) in
                    self.showButtons()
                }
            } failure: { (error) in
                self.showButtons()
            }
        } else {
            self.showButtons()
        }
    }

    private func setupButtons() {
        lichessButton.alpha = 0
        anonimousButton.alpha = 0
    }

    private func showButtons() {
        UIView.animate(withDuration: 0.4) {
            self.lichessButton.alpha = 1
            self.anonimousButton.alpha = 1
        }
    }

    private func onAccountRetrieved(_ account: Account) {
        UserData.shared.account = account
        openHome()
    }

    private func openHome() {
        let homeVC = HomeVC()
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = .fade
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(homeVC, animated: false)
    }

    @IBAction func lichessTapped() {
        lichessButton.isUserInteractionEnabled = false
        Auth().authenticate(self) {
            self.getAccount { (account) in
                self.lichessButton.isUserInteractionEnabled = true
                self.onAccountRetrieved(account)
            } failure: { (error) in
                self.lichessButton.isUserInteractionEnabled = true
            }
        } failure: { (error) in
            self.lichessButton.isUserInteractionEnabled = true
        }
    }

    @IBAction func anonimousTapped() {
        navigationController?.pushViewController(HomeVC(), animated: false)
    }
}
