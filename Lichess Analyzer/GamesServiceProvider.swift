//
//  GamesServiceProvider.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation

protocol GamesServiceProvider: BaseNetworkProvider {}

fileprivate let baseURL = "https://lichess.org/api/games/user/"

extension GamesServiceProvider {

    func getGames(user: String,
                  max: Int? = nil,
                  color: Color,
                  type: GameType?,
                  rated: Bool,
                  success: @escaping ([GameItem]?) -> (),
                  failure: @escaping (Error) -> ()) {
        let urlString = baseURL + user
        let params = ["max": max?.description ?? "", "color": color.rawValue, "perfType": type?.rawValue ?? "", "rated": rated.description, "opening": "true", "pgnInJson": "true"]
        let request = try? createRequest(.get, urlString, params)
        basicCall(request!) { (data) in
            success(self.mapGames(data.stringUTF8()))
        } failure: { (error) in

        }

    }

    func mapGames(_ string: String?) -> [GameItem]? {
        guard let string = string else { return nil }
        var arr = string.components(separatedBy: "[Ev")
        arr.removeFirst()
        let games = arr.map({mapString($0)}).compactMap({$0})
        if UserData.shared.search.gameType != .all {
        return games.filter({$0.event == UserData.shared.search.gameType})
        } else { return games }
    }

    func mapString(_ string: String) -> GameItem? {
        guard let event = string.slice(from: "ent ", to: "]"),
              let site = string.slice(from: "[Site ", to: "]"),
              let date = string.slice(from: "[Date ", to: "]"),
              let white = string.slice(from: "[White ", to: "]"),
              let black = string.slice(from: "[Black ", to: "]"),
              let result = string.slice(from: "[Result ", to: "]"),
              let termination = string.slice(from: "[Termination ", to: "]") else { return nil }
        return GameItem(event: GameType.extract(event),
                    site: site,
                    date: date,
                    white: white,
                    black: black,
                    result: result,
                    whiteElo: Int(string.slice(from: "[WhiteElo ", to: "]") ?? ""),
                    blackElo: Int(string.slice(from: "[BlackElo ", to: "]") ?? ""),
                    termination: termination,
                    completeOpening: string.slice(from: "[Opening ", to: "]") ?? "",
                    opening: KnownOpening.fromString(string.slice(from: "[Opening ", to: "]") ?? ""),
                    pgn: string.slice(from: "1. ", to: string.last!.description),
                    eco: KnownEco.fromString(string.slice(from: "[ECO ", to: "]") ?? ""))
    }
}

extension String {

    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo]).replacingOccurrences(of: "\"", with: "")
            }
        }
    }
}
