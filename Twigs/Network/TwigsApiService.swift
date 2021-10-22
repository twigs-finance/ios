//
//  BudgetApiService.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class TwigsApiService {
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
        return requestHelper.get("/api/budgets", queries: queries)
    }
    
    func getBudget(_ id: String) -> AnyPublisher<Budget, NetworkError> {
        return requestHelper.get("/api/budgets/\(id)")
    }
    
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return requestHelper.post("/api/budgets", data: budget, type: Budget.self)
    }
    
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return requestHelper.put("/api/budgets/\(budget.id)", data: budget)
    }
    
    func deleteBudget(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return requestHelper.delete("/api/budgets/\(id)")
    }
    
    // MARK: Transactions
    
    func getTransactions(
        budgetIds: [String]? = nil,
        categoryIds: [String]? = nil,
        from: Date? = nil,
        to: Date? = nil,
        count: Int? = nil,
        page: Int? = nil
    ) -> AnyPublisher<[Transaction], NetworkError> {
        var queries = [String: Array<String>]()
        if budgetIds != nil {
            queries["budgetIds"] = budgetIds!
        }
        if categoryIds != nil {
            queries["categoryIds"] = categoryIds!
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
        return requestHelper.get("/api/transactions", queries: queries)
    }
    
    func getTransaction(_ id: String) -> AnyPublisher<Transaction, NetworkError> {
        return requestHelper.get("/api/transactions/\(id)")
    }
    
    func newTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return requestHelper.post("/api/transactions", data: transaction, type: Transaction.self)
    }
    
    func updateTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return requestHelper.put("/api/transactions/\(transaction.id)", data: transaction)
    }
    
    func deleteTransaction(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return requestHelper.delete("/api/transactions/\(id)")
    }
    
    func sumTransactions(budgetId: String? = nil, categoryId: String? = nil, from: Date? = nil, to: Date? = nil) -> AnyPublisher<BalanceResponse, NetworkError> {
        var queries = [String: Array<String>]()
        if let budgetId = budgetId {
            queries["budgetId"] = [budgetId]
        }
        if let categoryId = categoryId {
            queries["categoryId"] = [categoryId]
        }
        if let from = from {
            queries["from"] = [from.toISO8601String()]
        }
        if let to = to {
            queries["to"] = [to.toISO8601String()]
        }
        return requestHelper.get("/api/transactions/sum", queries: queries)
    }
    
    // MARK: Categories
    
    func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Category], NetworkError> {
        var queries = [String: Array<String>]()
        if budgetId != nil {
            queries["budgetIds"] = [String(budgetId!)]
        }
        if expense != nil {
            queries["expense"] = [String(expense!)]
        }
        if archived != nil {
            queries["archived"] = [String(archived!)]
        }
        if count != nil {
            queries["count"] = [String(count!)]
        }
        if (page != nil) {
            queries["page"] =  [String(page!)]
        }
        return requestHelper.get("/api/categories", queries: queries)
    }
    
    func getCategory(_ id: String) -> AnyPublisher<Category, NetworkError> {
        return requestHelper.get("/api/categories/\(id)")
    }
    
    func getCategoryBalance(_ id: String) -> AnyPublisher<Int, NetworkError> {
        return requestHelper.get("/api/categories/\(id)/balance")
    }
    
    func newCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return requestHelper.post("/api/categories", data: category, type: Category.self)
    }
    
    func updateCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return requestHelper.put("/api/categories/\(category.id)", data: category)
    }
    
    func deleteCategory(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return requestHelper.delete("/api/categories/\(id)")
    }
    
    // MARK: Users
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, NetworkError> {
        return requestHelper.post(
            "/api/users/login",
            data: LoginRequest(username: username, password: password),
            type: LoginResponse.self
        ).map { (session) -> LoginResponse in
            return session
        }.eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError> {
        return requestHelper.post(
            "/api/users/register",
            data: RegistrationRequest(username: username, email: email, password: password),
            type: User.self
        ).map { (user) -> User in
            // Persist the credentials on sucessful registration
            return user
        }.eraseToAnyPublisher()
    }
    
    func getUser(id: String) -> AnyPublisher<User, NetworkError> {
        return requestHelper.get("/api/users/\(id)")
    }
    
    func searchUsers(query: String) -> AnyPublisher<[User], NetworkError> {
        return requestHelper.get(
            "/api/users/search",
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
        return requestHelper.get("/api/Users", queries: queries)
    }
    
    func newUser(_ user: User) -> AnyPublisher<User, NetworkError> {
        return requestHelper.post("/api/users", data: user, type: User.self)
    }
    
    func updateUser(_ user: User) -> AnyPublisher<User, NetworkError> {
        return requestHelper.put("/api/users/\(user.id)", data: user)
    }
    
    func deleteUser(_ user: User) -> AnyPublisher<Empty, NetworkError> {
        return requestHelper.delete("/api/users/\(user.id)")
    }
}

class RequestHelper {
    let decoder = JSONDecoder()
    let baseUrl: String
    var token: String?
    
    init(_ baseUrl: String) {
        self.baseUrl = baseUrl
        self.decoder.dateDecodingStrategy = .formatted(Date.iso8601DateFormatter)
    }
    
    func get<ResultType: Codable>(
        _ endPoint: String,
        queries: [String: Array<String>]? = nil
    ) -> AnyPublisher<ResultType, NetworkError> {
        var combinedEndPoint = endPoint
        if (queries != nil) {
            for (key, values) in queries! {
                for value in values {
                    let separator = combinedEndPoint.contains("?") ? "&" : "?"
                    combinedEndPoint += separator + key + "=" + value
                }
            }
        }
        
        return buildRequest(endPoint: combinedEndPoint, method: "GET")
    }
    
    func post<ResultType: Codable>(
        _ endPoint: String,
        data: Codable,
        type: ResultType.Type
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
    
    func delete(_ endPoint: String) -> AnyPublisher<Empty, NetworkError> {
        // Delete requests return no body so they need a special request helper
        guard let url = URL(string: self.baseUrl + endPoint) else {
            return Result.Publisher(.failure(.invalidUrl)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (_, res) -> Empty in
                guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    switch (res as? HTTPURLResponse)?.statusCode {
                    case 400: throw NetworkError.badRequest
                    case 401, 403: throw NetworkError.unauthorized
                    case 404: throw NetworkError.notFound
                    default: throw NetworkError.unknown
                    }
                }
                return Empty()
            }
            .mapError {
                return NetworkError.jsonParsingFailed($0)
            }
        return task.eraseToAnyPublisher()
    }
    
    private func buildRequest<ResultType: Codable>(
        endPoint: String,
        method: String,
        data: Encodable? = nil
    ) -> AnyPublisher<ResultType, NetworkError> {
        
        guard let url = URL(string: self.baseUrl + endPoint) else {
            return Result.Publisher(.failure(.invalidUrl)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpBody = data?.toJSONData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, res) -> Data in
                guard let response = res as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    switch (res as? HTTPURLResponse)?.statusCode {
                    case 400: throw NetworkError.badRequest
                    case 401, 403: throw NetworkError.unauthorized
                    case 404: throw NetworkError.notFound
                    default: throw NetworkError.unknown
                    }
                }
//                print(String(data: data, encoding: String.Encoding.utf8))
                return data
            }
            .decode(type: ResultType.self, decoder: self.decoder)
            .mapError {
                return NetworkError.jsonParsingFailed($0)
            }
            .eraseToAnyPublisher()
    }
}

struct Empty: Codable {}

enum NetworkError: Error, Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.unknown, .unknown):
            return true
        case (.notFound, .notFound):
            return true
        case (.unauthorized, .unauthorized):
            return true
        case (.badRequest, .badRequest):
            return true
        case (.invalidUrl, .invalidUrl):
            return true
        case (let .jsonParsingFailed(error1), let .jsonParsingFailed(error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
    
    var name: String {
        get {
            switch self {
            case .loading:
                return "loading"
            case .unknown:
                return "unknown"
            case .notFound:
                return "notFound"
            case .deleted:
                return "deleted"
            case .unauthorized:
                return "unauthorized"
            case .badRequest:
                return "badRequest"
            case .invalidUrl:
                return "invalidUrl"
            case .jsonParsingFailed(_):
                return "jsonParsingFailed"
            }
        }
    }
    
    case loading
    case unknown
    case notFound
    case deleted
    case unauthorized
    case badRequest
    case invalidUrl
    case jsonParsingFailed(Error)
}

extension Encodable {
    func toJSONData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }
}

extension Date {
    static let iso8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()
    
    static let localeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale.current)
        return dateFormatter
    }()
    
    func toISO8601String() -> String {
        return Date.iso8601DateFormatter.string(from: self)
    }
    
    func toLocaleString() -> String {
        return Date.localeDateFormatter.string(from: self)
    }
}
