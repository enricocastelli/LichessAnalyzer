//
//  UserData.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 25/10/2020.
//

import Foundation

class UserData: StoreProvider {

    static let shared = UserData()
    var search: SearchItem {
        get {
            getSearch() }
        set {
            storeSearch(newValue)
        }
    }
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
    var account: Account? 

    func isLoggedIn() -> Bool {
        return account != nil
    }

    func updateOpenings() {
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
                } catch(let error) {
                    print(error, "nope")
                }
            }
        }
    }

    func estimatedDownloadTime() -> Double? {
        guard let max = search.max else { return nil }
        return Double(max)/(UserData.shared.isLoggedIn() ? 60.0 : 20.0)
    }
}
