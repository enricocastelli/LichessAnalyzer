//
//  UserData.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 25/10/2020.
//

import Foundation

class UserData: StoreProvider {

    static let shared = UserData()
    var search: SearchItem = SearchItem(searchName: "", gameType: .all)
    var searchName: String {
        account?.username ?? ""
    }
    var preferredSorting: GamesSorting {
        get {
            getPreferredSorting() }
        set {
            storePreferredSorting(newValue)
        }
    }
    var token = ""
    var openings = [OpeningObject]()
    var knownOpenings = [KnownOpening]()
    var account: Account?
    var games: [GameItem] = [] {
        didSet {
            NotificationCenter.default.post(Notification(name: .NewGames))
        }
    }

    func isLoggedIn() -> Bool {
        return account != nil
    }

    func updateOpenings() {
        updateKnownOpenings()
        if let path = Bundle.main.path(forResource: "Openings", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    self.openings = try JSONDecoder().decode([OpeningObject].self, from: Data(jsonData))
                    self.openings.sort { (o1, o2) -> Bool in
                        return o1.pgn.count < o2.pgn.count
                    }
                    self.openings.sort { (o1, o2) -> Bool in
                        return o1.id < o2.id
                    }
//                    var duplicate = [String: String]()
//                    for open in openings {
//                        if duplicate[open.name] == open.id {
//                            print(open.name)
//                        } else {
//                            duplicate[open.name] = open.id
//                        }
//                    }
                } catch(let error) {
                    print(error, "nope")
                }
            }
        }
    }

    func updateKnownOpenings() {
        if let path = Bundle.main.path(forResource: "KnownOpenings", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    self.knownOpenings = try JSONDecoder().decode([OpeningObject].self, from: Data(jsonData))
                } catch(let error) {
                    print(error, "nope")
                }
            }
        }
    }
}
