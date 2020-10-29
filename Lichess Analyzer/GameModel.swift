//
//  GameModel.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import Foundation

struct GameItem: Encodable, Decodable, StructDecoder, Equatable {

    static var EntityName = "SavedGame"

    let event: String
//    let site: String
    let date: String
    let white: String
    let black: String
    let result: String
//    let whiteElo: Int?
//    let blackElo: Int?
    let termination: String
    let openingString: String
    let pgn: String?
    let eco: String

    var gameType: GameType {
        return GameType.extract(event)
    }
    var opening: KnownOpening {
        return KnownOpening.fromItem(self)
    }
    var completeOpening: CompleteOpening {
        return CompleteOpening.create(self)
    }
    var winner: String? {
        if result == "0-1" {
            return black
        } else if result == "1-0" {
            return white
        }
        return nil
    }

    var validDate: Date {
        return date.toDate("yyyy-MM-dd'H'HH-mmm-ss") ?? Date()
    }

    func resultForPlayer() -> Result {
        if winner == nil { return .draw }
        return winner == UserData.shared.searchName ? .win : .lose
    }

}

extension Array where Element == GameItem {

    func wins() -> Int {
        return filter({$0.resultForPlayer() == .win}).count
    }

    func lost() -> Int {
        return filter({$0.resultForPlayer() == .lose}).count
    }

    func draw() -> Int {
        return filter({$0.resultForPlayer() == .draw}).count
    }

    var points: Int {
        return map({$0.resultForPlayer().points}).reduce(0, +)
    }

    func mostCommonOpenings() -> [String: Int] {
        var sameOpeningList = [String: Int]()
        for game in self {
            guard let pgn = game.pgn, let moves = try? PGN.init(parse: pgn), moves.moves.count > 6 else { return ["":0] }
            let movs = moves.moves[0] + moves.moves[2] + moves.moves[4] + moves.moves[6]
            if (sameOpeningList[movs] != nil) {
                sameOpeningList[movs]! += 1
            } else {
                sameOpeningList[movs] = 1
            }
        }
        return sameOpeningList
    }

    private func combinePGN(_ pgn1: String, pgn2: String) -> String {
        return pgn1.sharedPrefix(with: pgn2)
    }
}

fileprivate extension String {
   func sharedPrefix(with other: String) -> String {
      return isEmpty || other.isEmpty ? "" : (first! != other.first! ? "" : "\(first!)" + String(Array(dropFirst())).sharedPrefix(with: String(Array(other.dropFirst()))))
   }
}

typealias KnownOpening = OpeningObject

extension KnownOpening {

    static func fromItem(_ item: GameItem) -> KnownOpening {
        let unknown = KnownOpening(id: "", name: "Other", pgn: "")
        let names = UserData.shared.knownOpenings.filter({item.openingString.contains($0.name)})
        return names.first ?? unknown
    }
}

typealias CompleteOpening = OpeningObject

extension CompleteOpening {

    static func create(_ item: GameItem) -> CompleteOpening {
        let unknown = CompleteOpening(id: "", name: "Unknown", pgn: "")
        guard let openings = UserData.shared.openings[item.eco] else { return unknown }
        return openings.filter({$0.name.lowercased() == item.openingString.lowercased()}).first ?? unknown
    }
}


struct OpeningObject: Codable, Equatable, Hashable {
    let id: String
    let name: String
    let pgn: String
}
