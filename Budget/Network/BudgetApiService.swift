//
//  BudgetApiService.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

class BudgetApiService {
    let requestHelper: RequestHelper
    
    init(requestHelper: RequestHelper) {
        self.requestHelper = requestHelper
    }
    
    func login(username: String, password: String, completionHandler: @escaping (User?, Error?) -> Void) throws {
        requestHelper.credentials = (username, password)
        try requestHelper.post(
            endPoint: "/users/login",
            data: LoginRequest(username: username, password: password),
            handler: completionHandler
        )
    }
        
    func getUser(id: UInt) throws -> User {
        throw NetworkError.notFound
    }
    
    func searchUsers(id: UInt) throws -> [User] {
        throw NetworkError.notFound
    }
}

class RequestHelper {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let baseUrl: String
    var credentials: (String, String)?
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func get<ResultType: Codable>(
        endPoint: String,
        queries: [String: Array<String>]? = nil,
        handler: @escaping (ResultType?, Error?) -> Void
    ) throws {
        var combinedEndPoint = endPoint
        if (queries != nil) {
            for (key, values) in queries! {
                for value in values {
                    let separator = endPoint.contains("?") ? "&" : "?"
                    combinedEndPoint += separator + key + "=" + value
                }
            }
        }
        
        try buildRequest(endPoint: endPoint, method: "GET", completionHandler: handler)
    }
    
    func post<ResultType: Codable>(
        endPoint: String,
        data: Codable,
        handler: @escaping (ResultType?, Error?) -> Void
    ) throws {
        try buildRequest(
            endPoint: endPoint,
            method: "POST",
            completionHandler: handler,
            data: data
        )
    }
    
    func put<ResultType: Codable>(
        endPoint: String,
        data: ResultType,
        handler: @escaping (ResultType?, Error?) -> Void
    ) throws {
        try buildRequest(
            endPoint: endPoint,
            method: "PUT",
            completionHandler: handler,
            data: data
        )
    }
    
    func delete<ResultType: Codable>(
        endPoint: String,
        handler: @escaping (ResultType?, Error?) -> Void
    ) throws {
        try buildRequest(endPoint: endPoint, method: "DELETE", completionHandler: handler)
    }

    private func buildRequest<ResultType: Codable>(
        endPoint: String,
        method: String,
        completionHandler: @escaping (ResultType?, Error?) -> Void,
        data: Encodable? = nil
    ) throws -> Void {
        guard let url = URL(string: baseUrl + endPoint) else {
            throw NetworkError.invalidUrl
        }
        var request = URLRequest(url: url)
        if (credentials != nil) {
            let encodedCredentials = "\(credentials!.0):\(credentials!.1)"
                .data(using: String.Encoding.utf8)?.base64EncodedString()
            if (encodedCredentials != nil) {
                request.addValue("Basic \(encodedCredentials!)", forHTTPHeaderField: "Authorization")
            }
        }
        request.httpBody = data?.toJSONData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse{
                print("Response code: \(httpResponse.statusCode)")
            }
            if (data == nil) {
                completionHandler(nil, error)
                return
            } else {
                if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    print(jsonResult)
                }
            }
            guard let result = try? self.decoder.decode(ResultType.self, from: data!) else {
                completionHandler(nil, error)
                return
            }
            completionHandler(result, error)
        }.resume()
    }
}

enum NetworkError: Error {
    case notFound
    case unauthorized
    case invalidUrl
}

extension Encodable {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
