//
//  GameModel.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import Foundation

struct GameItem: Encodable, Decodable {

    let event: GameType
    let site: String
    let date: String
    let white: String
    let black: String
    let result: String
    let whiteElo: Int?
    let blackElo: Int?
    let termination: String
    let completeOpening: String
    var opening: KnownOpening {
        return KnownOpening.fromItem(self)
    }
    let pgn: String?
    let eco: String

    var winner: String? {
        if result == "0-1" {
            return black
        } else if result == "1-0" {
            return white
        }
        return nil
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

    func mapToOpening() -> [OpeningGame] {
        var openings = [OpeningGame]()
        for game in self {
            if let index = openings.firstIndex(where: {$0.opening == game.opening}) {
                // a opening supergroup is existing
                var toUpdateOpening = openings[index]
                if let index = toUpdateOpening.completeOpenings.firstIndex(where: {$0.completeOpening == game.completeOpening}) {
                    // a opening subgroup is existing
                    toUpdateOpening.completeOpenings[index].results.append(game.resultForPlayer())
                    toUpdateOpening.completeOpenings[index].pgn = combinePGN(toUpdateOpening.completeOpenings[index].pgn, pgn2: game.pgn ?? "")
                } else {
                    // no opening subgroup is existing
                    toUpdateOpening.completeOpenings.append(CompleteOpeningGame(results: [game.resultForPlayer()], completeOpening: game.completeOpening, pgn: game.pgn ?? "", eco: game.eco))
                }
                toUpdateOpening.results.append(game.resultForPlayer())
                openings[index] = toUpdateOpening
            } else {
                // no opening supergroup is existing
                openings.append(OpeningGame(opening: game.opening,
                                            eco: game.eco,
                                            completeOpenings: [CompleteOpeningGame(results: [game.resultForPlayer()], completeOpening: game.completeOpening, pgn: game.pgn ?? "", eco: game.eco)],
                                            results: [game.resultForPlayer()]))
            }
        }
        return openings
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

struct OpeningGame: Equatable {

    var opening: KnownOpening
    var eco: String
    var completeOpenings: [CompleteOpeningGame]
    var results: [Result]
    var points: Int {
        return results.map({$0.points}).reduce(0, +)
    }
}

typealias KnownOpening = OpeningObject

extension KnownOpening {

    static func fromItem(_ item: GameItem) -> KnownOpening {
        let unknown = KnownOpening(id: item.eco, name: "Other", pgn: item.pgn ?? "")
        let names = UserData.shared.knownOpenings.filter({item.completeOpening.contains($0.name)})
        if !names.isEmpty {
            return names.first!
        }
        guard let pgn = item.pgn else { return unknown}
        let pgns = UserData.shared.knownOpenings.filter({ PGN.comparePGN($0.pgn, pgn) }).first ??
            UserData.shared.knownOpenings.filter({ PGN.similar($0.pgn, pgn) }).first
        if pgns == nil {
            Logger.warning(item.completeOpening)
        }
        return pgns ?? unknown
    }


}


struct CompleteOpeningGame: Equatable {
    var results: [Result]
    let completeOpening: String
    var pgn: String
    var eco: String
    var points: Int {
        return results.map({$0.points}).reduce(0, +)
    }

    var openingObject: OpeningObject? {
        var mostSimilar: OpeningObject?
        for op in UserData.shared.openings {
            guard op.id == self.eco else { continue }
            if op.name.lowercased() == self.completeOpening.lowercased() {
                return op
            } else if completeOpening.lowercased() == op.name.lowercased() || completeOpening.lowercased().contains(op.name.lowercased()) {
                mostSimilar = op
            }
        }
        return mostSimilar
    }
}


struct OpeningObject: Codable, Equatable {
    let id: String
    let name: String
    let pgn: String
}
