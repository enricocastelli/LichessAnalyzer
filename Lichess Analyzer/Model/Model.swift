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

    case accountCreation, lastYear, last6Months, lastMonth, _15Days, _7Days, today

    func desc() -> String {
        switch self {
        case .accountCreation: return "since account creation"
        case .lastYear: return "last year"
        case .last6Months: return "last 6 months"
        case .lastMonth: return "last month"
        case ._15Days: return "last 15 days"
        case ._7Days: return "last 7 days"
        case .today: return "today"
        }
    }

    func date() -> Date? {
        switch self {
        case .accountCreation: return Date(timeIntervalSince1970: 0)
        case .lastYear: return Calendar.current.date(byAdding: .year, value: -1, to: Date())
        case .last6Months: return Calendar.current.date(byAdding: .month, value: -6, to: Date())
        case .lastMonth: return Calendar.current.date(byAdding: .month, value: -1, to: Date())
        case ._15Days: return Calendar.current.date(byAdding: .day, value: -15, to: Date())
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
    var timing: Timing

    static var empty: Filter = Filter(sorting: .mostPlayed,
                                      color: .blackAndWhite,
                                      termination: .allTermination,
                                      timing: .accountCreation)

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

