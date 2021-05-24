//
//  ChessComGame.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 24/05/2021.
//

import Foundation



import Foundation

// MARK: - ChesscomGames
struct ChesscomGames: Codable {
    let games: [ChesscomGame]
}

// MARK: - Game
struct ChesscomGame: Codable {  
    let url: String
    let pgn, timeControl: String
    let endTime: Int
    let rated: Bool
    let fen: String
    let startTime: Int?
    let timeClass: TimeClass
    let white, black: ChessPlayer
    let tournament: String?

    enum CodingKeys: String, CodingKey {
        case url, pgn
        case timeControl = "time_control"
        case endTime = "end_time"
        case rated, fen
        case startTime = "start_time"
        case timeClass = "time_class"
        case white, black, tournament
    }

    func toGameItem() -> GameItem {
        return GameItem(
            event: timeClass.rawValue,
            date: Date(timeIntervalSince1970: TimeInterval(startTime ?? endTime)).toString() ?? "",
            white: white.username == "GigaOne" ? "polistirolo99" : white.username,
            black: black.username == "GigaOne" ? "polistirolo99" : black.username,
            result: extractResult(),
            site: url,
            termination: termination(),
            openingString: extractOpening() ?? "",
            pgn: pgn,
            eco: extractEco() ?? "")
    }

    private func extractEco() -> String? {
        return pgn.slice(from: "[ECO \"", to: "]")
    }

    private func extractOpening() -> String? {
        return pgn.slice(from: "https://www.chess.com/openings/", to: "]")?
            .replacingOccurrences(of: "-", with: " ")
    }

    private func extractResult() -> String {
        return pgn.slice(from: "Result ", to: "]") ?? ""
    }

    private func termination() -> String {
        switch white.result {
        case .win, .checkmated: return "Mate"
        case .resigned: return "Resign"
        case .timeout: return "Time"
        }
    }
}

// MARK: - Black
struct ChessPlayer: Codable {
    let rating: Int
    let result: ChessResult
    let id: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case rating, result
        case id = "@id"
        case username
    }
}

enum ChessResult: String, Codable {
    case checkmated = "checkmated"
    case resigned = "resigned"
    case timeout = "timeout"
    case win = "win"
}

enum TimeClass: String, Codable {
    case blitz = "blitz"
    case bullet = "bullet"
    case daily = "daily"
}
