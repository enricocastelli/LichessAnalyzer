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

enum Color: String, Decodable, Encodable {
    case black, white, all

    func desc() -> String {
        switch self {
        case .white, .black: return rawValue
        case .all: return "black & white"
        }
    }
}

enum Result {
    case win, lose, draw

    var points: Int {
        switch self {
        case .win: return 5
        case .draw: return 1
        case .lose: return -5
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
    var max: Int?,
        since: Timing?,
        searchName: String?,
        color: Color,
        rated: Bool,
        nonExpired: Bool,
        gameType: GameType

    var attrString: NSMutableAttributedString {
        let max = UserData.shared.search.max
        return NSMutableAttributedString()
        .bold(UserData.shared.search.rated ? "Rated games " : "Every game ")
        .normal("using ")
        .bold(UserData.shared.search.color.desc())
        .normal(" in ")
        .bold(UserData.shared.search.gameType.rawValue)
        .normal(" type games, ")
        .normal(max == nil ? "" : "last ")
        .bold(max == nil ? "" : max!.description)
        .normal(max == nil ? "" : " ")
        .bold(UserData.shared.search.since?.desc() ?? "")
    }
}

enum KnownOpening: String, Codable {

    case unknown = "unknown"
    case sicilian_defense = "Sicilian Defense"
    case ruy_lopez = "Ruy Lopez"
    case english_opening = "English Opening"
    case grob_opening = "Grob Opening"
    case queens_gambit = "Queen's Gambit"
    case kings_gambit = "King's Gambit"
    case caro__kann_defense = "Caro-Kann Defense"
    case italian_game = "Italian Game"
    case french_defense = "French Defense"
    case nimzowitsch_defense = "Nimzowitsch Defense"
//    case queens_gambit_declined = "Queen's Gambit Declined"
//    case kings_gambit_declined = "King's Gambit Declined"
//    case queens_gambit_accepted = "Queen's Gambit Accepted"
//    case hungarian_opening = "Hungarian Opening"
//    case zukertort_opening = "Zukertort Opening"
//    case colle_system = "Colle System"
//    case van_geet_opening = "Van Geet Opening"
//    case grand_prix = "Grand Prix"
//    case fools_mate = "Fool's Mate"
//    case ponziani_gambit = "Ponziani Gambit"
//    case bishops_opening = "Bishop's Opening"
//    case bongcloud_attack = "Bongcloud Attack"
//    case bird_opening = "Bird Opening"
//    case duras_gambit = "Duras Gambit"
//    case scandinavian_defense = "Scandinavian Defense"
//    case reti_opening = "Reti Opening"
//    case kadas_opening = "Kadas Opening"
//    case crab_opening = "Crab Opening"
//    case ware_opening = "Ware Opening"
//    case nimzo__larsen_attack = "Nimzo - Larsen Attack"
//    case king_pawn = "King Pawn"
//    case king_pawns_game = "King Pawn's Game"
//    case gedults_opening = "Gedult's Opening"
//    case semislav_meran = "Semi-Slav Meran"
//    case hungarian_defense = "Hungarian Defense"
//    case benoni_defense = "Benoni Defense"
//    case indian_game = "Indian Game"
//    case philidor_defense = "Philidor Defense"
//    case kings_pawn_game = "King's Pawn Game"
//    case modern_defense = "Modern Defense"
//    case pirc_defense = "Pirc Defense"
//    case latvian_gambit_accepted = "Latvian Gambit Accepted"
//    case owen_defense = "Owen Defense"
//    case four_knights_game = "Four Knights Game"
//    case vant_kruijs_opening = "Van't Kruijs Opening"
//    case alekhine_defense = "Alekhine Defense"
//    case elephant_gambit = "Elephant Gambit"
//    case giuoco_piano = "Giuoco Piano"
//    case st_george_defense = "St. George Defense"
//    case three_knights_opening = "Three Knights Opening"
//    case russian_game = "Russian Game"
//    case barnes_defense = "Barnes Defense"
//    case clemenz_opening = "Clemenz Opening"
//    case englund_gambit_declined = "Englund Gambit Declined"
//    case englund_gambit = "Englund Gambit"
//    case saragossa_opening = "Saragossa Opening"
//    case réti_opening = "Réti Opening"
//    case kings_indian_attack = "King's Indian Attack"
//    case mieses_opening = "Mieses Opening"
//    case englund_gambit_complex = "Englund Gambit Complex"
//    case polish_opening = "Polish Opening"
//    case scotch_game = "Scotch Game"
//    case queens_pawn_game = "Queen's Pawn Game"
//    case blackmardiemer_gambit = "Blackmar-Diemer Gambit"
//    case nimzolarsen_attack = "Nimzo-Larsen Attack"
//    case englund_gambit_complex_declined = "Englund Gambit Complex Declined"
//    case amar_opening = "Amar Opening"
//    case old_indian_defense = "Old Indian Defense"
//    case vienna_game = "Vienna Game"
//    case center_game = "Center Game"
//    case catalan_opening = "Catalan Opening"
//    case slav_defense = "Slav Defense"
//    case kangaroo_defense = "Kangaroo Defense"
//    case nimzoindian_defense = "Nimzo-Indian Defense"
//    case dutch_defense = "Dutch Defense"
//    case slav_indian = "Slav Indian"
//    case semislav_defense = "Semi-Slav Defense"
//    case english_defense = "English Defense"
//    case queens_indian_accelerated = "Queen's Indian Accelerated"
//    case horwitz_defense = "Horwitz Defense"
//    case old_benoni_defense = "Old Benoni Defense"
//    case mexican_defense = "Mexican Defense"
//    case grünfeld_defense = "Grünfeld Defense"
//    case kings_indian_defense = "King's Indian Defense"
//    case robatsch_modern_defense = "Robatsch (Modern) Defense"
//    case francobenoni_defense = "Franco-Benoni Defense"
//    case blackmar_gambit = "Blackmar Gambit"
//    case polish_defense = "Polish Defense"
//    case czech_defense = "Czech Defense"
//    case richterveresov_attack = "Richter-Veresov Attack"
//    case trompowsky_attack = "Trompowsky Attack"
//    case pterodactyl_defense = "Pterodactyl Defense"
//    case borg_defense = "Borg Defense"
//    case rapportjobava_system = "Rapport-Jobava System"
//    case budapest_defense = "Budapest Defense"
//    case queens_pawn = "Queen's Pawn"
//    case ware_defense = "Ware Defense"
//    case london_system = "London System"
//    case tarrasch_defense = "Tarrasch Defense"
//    case latvian_gambit = "Latvian Gambit"
//    case kings_knight_opening = "King's Knight Opening"


    static func fromString(_ string: String) -> KnownOpening {
        let superOpening = String(string.split(separator: ":").first ?? "")
        let optionOpening = String(string.split(separator: ",").first ?? "")
        if let knownOpening = KnownOpening(rawValue: superOpening) {
            return knownOpening
        } else if let optionOpening = KnownOpening(rawValue: optionOpening) {
            return optionOpening
        } else {
            print("case \(superOpening.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "-", with: "")) = " + "\"" + "\(superOpening)" + "\"")
            return .unknown
        }
    }
}

enum GamesSorting: String {
    case mostPlayed, weakest, strongest

    func desc() -> String {
        switch self {
        case .mostPlayed: return "Most played"
        case .weakest: return "Weakest"
        case .strongest: return "Strongest"
        }
    }
}

