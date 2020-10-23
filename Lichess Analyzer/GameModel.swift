//
//  GameModel.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 22/10/2020.
//

import Foundation

struct GameItem {

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
    let opening: KnownOpening
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
        return winner == UserData.shared.name ? .win : .lose
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

struct CompleteOpeningGame: Equatable {
    var results: [Result]
    let completeOpening: String
    var pgn: String
    var eco: String
    var points: Int {
        return results.map({$0.points}).reduce(0, +)
    }

    var openingObject: OpeningObject? {
        var mostSimilarOp: OpeningObject?
        for op in UserData.shared.openings {
            if op.id == self.eco {
                if completeOpening.lowercased() == op.name.lowercased() || completeOpening.lowercased().contains(op.name.lowercased()) {
                    mostSimilarOp = op
                    break
                }
            }
        }
        let similarity = StringSimilarity.levenshtein(aStr: mostSimilarOp?.name.lowercased() ?? " ", bStr: completeOpening.lowercased())
        guard similarity <= 10 else { return nil }
        return mostSimilarOp
    }
}


struct OpeningObject: Codable, Equatable {
    let id: String
    let name: String
    let pgn: String
}
