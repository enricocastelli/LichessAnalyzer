//
//  Logger.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation

class Logger {

    static func error(_ error: Error,_ request: URLRequest? = nil) {
        let requestString = request?.url?.absoluteString ?? ""
        switch error.self {
        case is NetworkError:
            print("⚠️💔 - ERROR - \(requestString) - \((error as! NetworkError).localizedDescription)")
        default:
            print("⚠️💔 - ERROR - \(requestString) - \((error as NSError).description)")
        }
    }

    static func warning(_ warning: String) {
        print("⚠️💙 - WARNING - \(warning)")
    }
}

extension Data {

    func prettyPrint() {
        print(stringUTF8() ?? "no data")
    }

    func stringUTF8() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }

}
