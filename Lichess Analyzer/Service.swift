//
//  Service.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 21/10/2020.
//

import Foundation


protocol BaseNetworkProvider {}

extension BaseNetworkProvider {


    func basicCall(_ request: URLRequest, success: @escaping (Data) -> (), failure: @escaping (Error) -> ()) {
        let task = Network.session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    Logger.error(error, request)
                    failure(error)
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    Logger.error(NetworkError.noData, request)
                    failure(NetworkError.noData)
                }
                return
            }
            guard self.isValidResponse(response) else {
                if self.isAuthError(response) {
                    DispatchQueue.main.async {
                        Logger.error(NetworkError.authError, request)
                        failure(NetworkError.authError)
                    }
                } else {
                    DispatchQueue.main.async {
                        let error = NetworkError.generalError(data, (response as? HTTPURLResponse)?.statusCode ?? 0)
                        Logger.error(error, request)
                        failure(error)
                    }
                }
                return
            }
            DispatchQueue.main.async {
                success(data)
            }
        }
        task.resume()
    }

    func createRequest(_ method: Verb, _ urlString: String, _ params: [String: String]? = nil) throws -> URLRequest {
        var request = URLRequest(url: try createURL(urlString, params),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: TimeInterval(60))
        request.httpMethod = method.rawValue
        request.httpShouldHandleCookies = true
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        return request
    }

    func createURL(_ urlString: String, _ params: [String: String]? = nil) throws -> URL{
        var queryItems = [URLQueryItem]()
        if let params = params {
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        guard var urlComps = URLComponents(string: urlString) else {
            throw NetworkError.badURL
        }
        urlComps.queryItems = queryItems
        guard let result = urlComps.url else {
            throw NetworkError.badURL
        }
        return result
    }

    func createAuthorizationString(_ method: Verb, _ url: URL) -> String {
        return ""
    }


    private func isValidResponse(_ response: URLResponse?) -> Bool {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return false }
        return statusCode == 200 || statusCode == 201 || statusCode == 202
    }

    private func isAuthError(_ response: URLResponse?) -> Bool {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return false }
        return statusCode == 401
    }
}

enum NetworkError: Error {
    case badURL
    case noData
    case generalError(_ data: Data, _ code: Int)
    case parsingError
    case authError
    case clientError
}

fileprivate class Network {

    public static let session = URLSession.shared

}


public enum Verb: String {
    case get, put, delete, post
}

extension Encodable {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
