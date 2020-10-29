//
//  GamesServiceProvider.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation

protocol ServiceProvider: BaseNetworkProvider {}

fileprivate let baseURL = "https://lichess.org/api/games/user/"
fileprivate let accountURL = "https://lichess.org/api/account"


extension ServiceProvider {

    func getGames(_ max: Int?,
                    sinceDate: Int? = nil,
                    untilDate: Int? = nil,
                  success: @escaping ([GameItem]?) -> (),
                  failure: @escaping (Error) -> ()) {
        let urlString = baseURL + UserData.shared.searchName
        let params = ["max": max?.description ?? "",
                      "until": untilDate?.description ?? "",
                      "since": sinceDate?.description ?? "",
                      "perfType": UserData.shared.search.gameType.rawValue,
                      "rated": "true",
                      "opening": "true"]
        let request = createRequest(.get, urlString, params)
        basicCall(request) { (data) in
            success(self.mapGames(data.stringUTF8()))
        } failure: { (error) in
            failure(error)
        }
    }

    func getAccount(success: @escaping (Account) -> (),
                    failure: @escaping (Error) -> ()) {
        let urlString = accountURL
        let request = createRequest(.get, urlString, nil)
        basicCall(request) { (data) in
            do {
                success(try JSONDecoder().decode(Account.self, from: data))
            } catch(let error) {
                failure(error)
            }
        } failure: { (error) in
            failure(error)
        }
    }

    func mapGames(_ string: String?) -> [GameItem]? {
        guard let string = string else { return nil }
        var arr = string.components(separatedBy: "[Ev")
        arr.removeFirst()
        let games = arr.map({mapString($0)}).compactMap({$0})
        //        if UserData.shared.search.nonExpired {
//        return games.filter({!$0.termination.contains("Time forfeit") })
//    } else {
//        return games
//    }
        return games
    }

    func mapString(_ string: String) -> GameItem? {
        guard let event = string.slice(from: "ent ", to: "]"),
//              let site = string.slice(from: "[Site ", to: "]"),
              let date = string.slice(from: "[UTCDate ", to: "]"),
              let time = string.slice(from: "[UTCTime ", to: "]"),
              let white = string.slice(from: "[White ", to: "]"),
              let black = string.slice(from: "[Black ", to: "]"),
              let result = string.slice(from: "[Result ", to: "]"),
              let termination = string.slice(from: "[Termination ", to: "]") else { return nil }
        return GameItem(event: event,
//                    site: site,
                    date: date + "H" + time,
                    white: white,
                    black: black,
                    result: result,
//                    whiteElo: Int(string.slice(from: "[WhiteElo ", to: "]") ?? ""),
//                    blackElo: Int(string.slice(from: "[BlackElo ", to: "]") ?? ""),
                    termination: termination,
                    completeOpening: string.slice(from: "[Opening ", to: "]") ?? "",
                    pgn: string.slice(from: "1. ", to: string.last!.description),
                    eco: string.slice(from: "[ECO ", to: "]") ?? "")
    }
}

