//
//  UserData.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 25/10/2020.
//

import Foundation

typealias U = UserData

class UserData: StoreProvider {

    static let shared = UserData()
    var search: SearchItem {
        get {
            getSearch() }
        set {
            storeSearch(newValue)
        }
    }
    var searchName: String = ""
    var filters: Filter {
        get {
            getfilters() }
        set {
            storeFilters(newValue)
        }
    }
    var token = ""
    var openings = [String: [OpeningObject]]()
    var knownOpenings = [OpeningObject]()
    var account: Account? {
        didSet {
            searchName = account?.username ?? ""
        }
    }
    var games: [GameItem] = [] {
        didSet {
            NotificationCenter.default.post(Notification(name: .NewGames))
        }
    }
    func isPlayer() -> Bool {
        return account?.username == searchName
    }

    func isLoggedIn() -> Bool {
        return account != nil
    }

    func updateOpenings() {
        updateKnownOpenings()
        Clock.start()
        if let path = Bundle.main.path(forResource: "Openings", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    var openings = try JSONDecoder().decode([OpeningObject].self, from: Data(jsonData))
                    openings.sort { (o1, o2) -> Bool in
                        return o1.pgn.count < o2.pgn.count
                    }
                    openings.sort { (o1, o2) -> Bool in
                        return o1.id < o2.id
                    }
                    self.openings = Dictionary(grouping: openings, by: { $0.id })

//                    var duplicate = [String: String]()
//                    for open in openings {
//                        if duplicate[open.name] == open.id {
//                            print(open.name)
//                        } else {
//                            duplicate[open.name] = open.id
//                        }
//                    }
                    Clock.stop()
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
