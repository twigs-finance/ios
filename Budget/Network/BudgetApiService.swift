//
//  BudgetApiService.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class BudgetApiService {
    let requestHelper: RequestHelper
    
    init(requestHelper: RequestHelper) {
        self.requestHelper = requestHelper
    }
    
    func login(username: String, password: String) -> AnyPublisher<User, NetworkError> {
        requestHelper.credentials = (username, password)
        return requestHelper.post(
            endPoint: "/users/login",
            data: LoginRequest(username: username, password: password)
        )
    }
    
    func getUser(id: Int) -> AnyPublisher<User, NetworkError> {
        return requestHelper.get(endPoint: "/users/\(id)")
    }
    
    func searchUsers(query: String) -> AnyPublisher<[User], NetworkError> {
        return requestHelper.get(
            endPoint: "/users/search",
            queries: ["query": [query]]
        )
    }
}

class RequestHelper {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let baseUrl: String
  // Note:
  // There shouldn't be a reason to sink when building a typical request.
    private var subscriptions = Set<AnyCancellable>()
    var credentials: (String, String)?
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func get<ResultType: Codable>(
        endPoint: String,
        queries: [String: Array<String>]? = nil
    ) -> AnyPublisher<ResultType, NetworkError> {
        var combinedEndPoint = endPoint
        if (queries != nil) {
            for (key, values) in queries! {
                for value in values {
                    let separator = endPoint.contains("?") ? "&" : "?"
                    combinedEndPoint += separator + key + "=" + value
                }
            }
        }
        
        return buildRequest(endPoint: endPoint, method: "GET")
    }
    
    func post<ResultType: Codable>(
        endPoint: String,
        data: Codable
    ) -> AnyPublisher<ResultType, NetworkError> {
        return buildRequest(
            endPoint: endPoint,
            method: "POST",
            data: data
        )
    }
    
    func put<ResultType: Codable>(
        endPoint: String,
        data: ResultType
    ) -> AnyPublisher<ResultType, NetworkError> {
        return buildRequest(
            endPoint: endPoint,
            method: "PUT",
            data: data
        )
    }
    
    func delete<ResultType: Codable>(endPoint: String) -> AnyPublisher<ResultType, NetworkError> {
        return buildRequest(endPoint: endPoint, method: "DELETE")
    }
    
    private func buildRequest<ResultType: Codable>(
        endPoint: String,
        method: String,
        data: Encodable? = nil
    ) -> AnyPublisher<ResultType, NetworkError> {
      
      guard let url = URL(string: self.baseUrl + endPoint) else {
        return Future<ResultType, NetworkError> { promise in
          promise(.failure(.invalidUrl))
        }.eraseToAnyPublisher()
      }
      
      var request = URLRequest(url: url)
      if (self.credentials != nil) {
          if let encodedCredentials = "\(self.credentials!.0):\(self.credentials!.1)"
              .data(using: String.Encoding.utf8)?.base64EncodedString() {
              request.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
          }
      }
      request.httpBody = data?.toJSONData()
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpMethod = method
      
      let task = URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { (data, res) -> Data in
          guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
            switch (res as? HTTPURLResponse)?.statusCode {
            case 400: throw NetworkError.badRequest
            case 401, 403: throw NetworkError.unauthorized
            case 404: throw NetworkError.notFound
            default: throw NetworkError.unknown
            }
          }
          return data
      }
      .decode(type: ResultType.self, decoder: JSONDecoder())
      .mapError {
          return NetworkError.jsonParsingFailed($0)
      }
      return task.eraseToAnyPublisher()
    }
}

enum NetworkError: Error {
    case unknown
    case notFound
    case unauthorized
    case badRequest
    case invalidUrl
    case jsonParsingFailed(Error)
}

extension Encodable {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
