//
//  Model.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation

enum GameType: String, Codable {

    case bullet, blitz, rapid, all

    static func extract(_ string: String) -> GameType {
        if string.contains("Blitz") {
            return .blitz
        } else if string.contains("Bullet") {
            return .bullet
        } else if string.contains("Rapid") {
            return .rapid
        }
        return .all
    }
}

enum Result {
    case win, lose, draw

    var points: Int {
        switch self {
        case .win: return 3
        case .draw: return 0
        case .lose: return -3
        }
    }
}

enum Timing: String, Decodable, Encodable {

    case accountCreation, beginningYear, beginningMonth, _20Days, _7Days, today

    func desc() -> String {
        switch self {
        case .accountCreation: return "since account creation"
        case .beginningYear: return "since beginning of the year"
        case .beginningMonth: return "since beginning of the month"
        case ._20Days: return "last 20 days"
        case ._7Days: return "last 7 days"
        case .today: return "today"
        }
    }

    func date() -> Date? {
        switch self {
        case .accountCreation: return Date(timeIntervalSince1970: 0)
        case .beginningYear: return "01-01-\(Date().year.description)".toDate()
        case .beginningMonth: return "01-\(Date().month.description)-\(Date().year.description)".toDate()
        case ._20Days: return Calendar.current.date(byAdding: .day, value: -20, to: Date())
        case ._7Days: return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .today: return Calendar.current.startOfDay(for: Date())
        }
    }
}

struct SearchItem: Encodable, Decodable {
    var searchName: String?,
        gameType: GameType
}

struct Filter: Encodable, Decodable {

    var sorting: GamesSorting
    var color: Color
    var termination: Termination

    static var empty: Filter = Filter(sorting: .mostPlayed,
                                      color: .blackAndWhite,
                                      termination: .allTermination)

}

enum GamesSorting: String, Encodable, Decodable {
    case mostPlayed, weakest, strongest

    func desc() -> String {
        switch self {
        case .mostPlayed: return "Most played"
        case .weakest: return "Weakest"
        case .strongest: return "Strongest"
        }
    }
}


enum Color: String, Encodable, Decodable {
    case black, white, blackAndWhite

    func desc() -> String {
        switch self {
        case .white, .black: return rawValue
        case .blackAndWhite: return "black & white"
        }
    }
}


enum Termination: String, Encodable, Decodable {
    case time, normal, allTermination

    func desc() -> String {
        switch self {
        case .time: return "Time"
        case .normal: return "Mate/Resign"
        case .allTermination: return "All"
        }
    }
}

