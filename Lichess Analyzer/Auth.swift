//
//  Auth.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 24/10/2020.
//

import Foundation
import OAuthSwift

let clientID = "xV98BnkMJDhc1P74"
let clientSecret = "La6uxXDEnAluNil7UkdXGmJKt12Bptp0"
let personalToken = "lvsWUhqbJyUl6Dxg"

class Auth: StoreProvider  {

    private let oauthswift = OAuth2Swift(consumerKey: clientID,
                                                     consumerSecret: clientSecret,
                                                     authorizeUrl: "https://oauth.lichess.org/oauth/authorize",
                                                     accessTokenUrl: "https://oauth.lichess.org/oauth", responseType: "code")

    func authenticate(_ handler: UIViewController?, success: @escaping () -> (),
    failure: @escaping (Error) -> ()) {
        if let handler = handler {
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: handler, oauthSwift: oauthswift)
        }
        oauthswift.authorize(withCallbackURL: "https://lichan.page.link", scope: "email:read", state: "lichess") { (result) in
            switch result {
            case .success(let (credential, _, _)):
                UserData.shared.token = credential.oauthToken
                self.storeRefreshToken(credential.oauthRefreshToken)
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }

    func renewToken(_ refreshToken: String, success: @escaping () -> (),
                    failure: @escaping (Error) -> ()) {
        oauthswift.renewAccessToken(withRefreshToken: refreshToken, completionHandler: { result in
            switch result {
            case .success(let (credential, _, _)):
                UserData.shared.token = credential.oauthToken
                self.storeRefreshToken(credential.oauthRefreshToken)
                success()
            case .failure(let error):
                failure(error)
                print(error.localizedDescription)
            }
        })
    }
}

