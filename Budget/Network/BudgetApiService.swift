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
    
    init(_ requestHelper: RequestHelper) {
        self.requestHelper = requestHelper
    }
    
    // MARK: Budgets
    
    func getBudgets(count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Budget], NetworkError> {
        var queries = [String: Array<String>]()
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return requestHelper.get("/budgets", queries: queries)
    }
    
    func getBudget(_ id: Int) -> AnyPublisher<Budget, NetworkError> {
        return requestHelper.get("/budgets/\(id)")
    }
    
    func getBudgetBalance(_ id: Int) -> AnyPublisher<Int, NetworkError> {
        return requestHelper.get("/budgets/\(id)/balance")
    }
    
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return requestHelper.post("/budgets/new", data: budget)
    }
    
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return requestHelper.put("/budgets/\(budget.id!)", data: budget)
    }
    
    // TODO: Figure out how to implement this
    //    func deleteBudget(_ id: Int) -> AnyPublisher<Void, NetworkError> {
    //        return requestHelper.delete("/budgets/\(id)")
    //    }
    
    // MARK: Transactions
    
    func getTransactions(
        budgetIds: [Int]? = nil,
        categoryIds: [Int]? = nil,
        from: Date? = nil,
        to: Date? = nil,
        count: Int? = nil,
        page: Int? = nil
    ) -> AnyPublisher<[Transaction], NetworkError> {
        var queries = [String: Array<String>]()
        if budgetIds != nil {
            queries["budgetId"] = budgetIds!.map { String($0) }
        }
        if categoryIds != nil {
            queries["categoryId"] = categoryIds!.map { String($0) }
        }
        if from != nil {
            queries["from"] = [from!.toISO8601String()]
        }
        if to != nil {
            queries["to"] = [to!.toISO8601String()]
        }
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return requestHelper.get("/transactions", queries: queries)
    }
    
    func getTransaction(_ id: Int) -> AnyPublisher<Transaction, NetworkError> {
        return requestHelper.get("/transactions/\(id)")
    }
    
    func newTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return requestHelper.post("/transactions/new", data: transaction)
    }
    
    func updateTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return requestHelper.put("/transactions/\(transaction.id!)", data: transaction)
    }
    
    // TODO: Figure out how to implement this
    //    func deleteTransaction(_ id: Int) -> AnyPublisher<Void, NetworkError> {
    //        return requestHelper.delete("/transactions/\(id)")
    //    }
    
    // MARK: Categories
    
    func getCategories(budgetId: Int? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Category], NetworkError> {
        var queries = [String: Array<String>]()
        if budgetId != nil {
            queries["budgetId"] = [String(budgetId!)]
        }
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return requestHelper.get("/categories", queries: queries)
    }
    
    func getCategory(_ id: Int) -> AnyPublisher<Category, NetworkError> {
        return requestHelper.get("/categories/\(id)")
    }
    
    func getCategoryBalance(_ id: Int) -> AnyPublisher<Int, NetworkError> {
        return requestHelper.get("/categories/\(id)/balance")
    }
    
    func newCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return requestHelper.post("/categories/new", data: category)
    }
    
    func updateCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return requestHelper.put("/categories/\(category.id!)", data: category)
    }
    
    // TODO: Figure out how to implement this
    //    func deleteCategory(_ id: Int) -> AnyPublisher<Void, NetworkError> {
    //        return requestHelper.delete("/categories/\(id)")
    //    }
    
    // MARK: Users
    func login(username: String, password: String) -> AnyPublisher<User, NetworkError> {
        requestHelper.credentials = (username, password)
        return requestHelper.post(
            "/users/login",
            data: LoginRequest(username: username, password: password)
        )
    }
    
    func getUser(id: Int) -> AnyPublisher<User, NetworkError> {
        return requestHelper.get("/users/\(id)")
    }
    
    func searchUsers(query: String) -> AnyPublisher<[User], NetworkError> {
        return requestHelper.get(
            "/users/search",
            queries: ["query": [query]]
        )
    }
    
    func getUsers(count: Int? = nil, page: Int? = nil) -> AnyPublisher<[User], NetworkError> {
        var queries = [String: Array<String>]()
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return requestHelper.get("/Users", queries: queries)
    }
    
    func newUser(_ user: User) -> AnyPublisher<User, NetworkError> {
        return requestHelper.post("/users/new", data: user)
    }
    
    func updateUser(_ user: User) -> AnyPublisher<User, NetworkError> {
        return requestHelper.put("/users/\(user.id!)", data: user)
    }
}

class RequestHelper {
    let encoder = JSONEncoder()
    let decoder: JSONDecoder
    let baseUrl: String
    var credentials: (String, String)?
    
    init(_ baseUrl: String) {
        self.baseUrl = baseUrl
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func get<ResultType: Codable>(
        _ endPoint: String,
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
        
            return buildRequest(endPoint: combinedEndPoint, method: "GET")
    }
    
    func post<ResultType: Codable>(
        _ endPoint: String,
        data: Codable
    ) -> AnyPublisher<ResultType, NetworkError> {
        return buildRequest(
            endPoint: endPoint,
            method: "POST",
            data: data
        )
    }
    
    func put<ResultType: Codable>(
        _ endPoint: String,
        data: ResultType
    ) -> AnyPublisher<ResultType, NetworkError> {
        return buildRequest(
            endPoint: endPoint,
            method: "PUT",
            data: data
        )
    }
    
    func delete<ResultType: Codable>(_ endPoint: String) -> AnyPublisher<ResultType, NetworkError> {
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
        .decode(type: ResultType.self, decoder: self.decoder)
        .mapError {
            return NetworkError.jsonParsingFailed($0)
        }
        return task.eraseToAnyPublisher()
    }
}

enum NetworkError: Error {
    case loading
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

extension Date {
    var iso8601DateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }
    
    var localeDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale.current)
        return dateFormatter
    }
    
    func toISO8601String() -> String {
        return iso8601DateFormatter.string(from: self)
    }
    
    func toLocaleString() -> String {
        return localeDateFormatter.string(from: self)
    }
}
