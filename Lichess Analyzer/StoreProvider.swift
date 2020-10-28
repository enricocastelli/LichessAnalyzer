//
//  StoreProvider.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 25/10/2020.
//

import Foundation

enum StoreKeys {
    static let isFirstTime = "isFirstTime"
    static let name = "name"
    static let refreshToken = "refreshToken"
    static let gamesBullet = "gamesBullet"
    static let lastDateBullet = "lastDateBullet"
    static let preferredSorting = "preferredSorting"
    static let search = "search"
}

protocol StoreProvider {}

extension StoreProvider {

    func storeFirstTime() {
        UserDefaults.standard.set(false, forKey: StoreKeys.isFirstTime)
    }

    func isFirstTime() ->  Bool {
//        if isSimulator() { return true }
        if let _ = UserDefaults.standard.object(forKey: StoreKeys.isFirstTime) as? Bool {
            return false
        } else {
            return true
        }
    }

    func storeName(_ name: String) {
        UserDefaults.standard.set(name, forKey: StoreKeys.name)
    }

    func getName() -> String? {
        return UserDefaults.standard.object(forKey: StoreKeys.name) as? String
    }


    func storeRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: StoreKeys.refreshToken)
    }

    func getRefreshToken() -> String? {
        return UserDefaults.standard.object(forKey: StoreKeys.refreshToken) as? String
    }

    func deleteRefreshToken() {
        UserDefaults.standard.removeObject(forKey: StoreKeys.refreshToken)
    }

    func storePreferredSorting(_ sorting: GamesSorting) {
        UserDefaults.standard.set(sorting.rawValue, forKey: StoreKeys.preferredSorting)
    }

    func getPreferredSorting() -> GamesSorting {
        if let preferred = UserDefaults.standard.object(forKey: StoreKeys.preferredSorting) as? String, let sort = GamesSorting(rawValue: preferred) {
            return sort
        }
        return GamesSorting.mostPlayed
    }

    func storeSearch(_ search: SearchItem) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(search), forKey:StoreKeys.search)
    }

    func getSearch() -> SearchItem {
        let base = SearchItem(max: 10, since: .beginningYear, searchName: nil, color: Color.white, rated: true, nonExpired: false, gameType: GameType.all)
        if let data = UserDefaults.standard.value(forKey:StoreKeys.search) as? Data {
            return (try? PropertyListDecoder().decode(SearchItem.self, from: data)) ?? base
        }
        return base
    }


    func storeGames(_ games: [GameItem], searchItem: SearchItem) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(games), forKey: searchItem.string)
    }

    func getGames(searchItem: SearchItem) -> [GameItem]? {
        if let data = UserDefaults.standard.value(forKey: searchItem.string) as? Data {
            return try? PropertyListDecoder().decode([GameItem].self, from: data)
        }
        return nil
    }
}


