//
//  AccountModel.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 25/10/2020.
//

import Foundation

struct Account: Codable {
    let id, username: String
    let perfs: Perfs
    let createdAt: Int
    let profile: NameCodable?
    private let count: [String: Int]

    var win: Int? {
        return count["win"]
    }

    var loss: Int? {
        return count["loss"]
    }

    var draw: Int? {
        return count["draw"]
    }

    var all: Int? {
        return count["all"]
    }

    func numberOfGamesForType(_ gameType: GameType) -> Int? {
        switch gameType {
        case .bullet: return perfs.bullet?.games
        case .blitz: return perfs.blitz?.games
        case .rapid: return perfs.rapid?.games
        case .all: return all
        }
    }

    func perfsAvailable() -> [GameType] {
        var array: [GameType] = []
        if numberOfGamesForType(.bullet) ?? 0 > 0 { array.append(.bullet) }
        if numberOfGamesForType(.blitz) ?? 0 > 0 { array.append(.blitz) }
        if numberOfGamesForType(.rapid) ?? 0 > 0 { array.append(.rapid) }
        if numberOfGamesForType(.all) ?? 0 > 0 { array.append(.all) }
        return array
    }
}

struct Perfs: Codable {
    let ultrabullet, bullet, blitz, rapid, classical: PerfsInfo?
}

struct PerfsInfo: Codable {
    let games, rating: Int
}

struct NameCodable: Codable {
    let firstName: String?
}
