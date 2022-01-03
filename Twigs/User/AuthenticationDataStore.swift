import Foundation
import Combine
import SwiftUI
import TwigsCore

class AuthenticationDataStore: ObservableObject {
    @Published var loading: Bool = false {
        didSet {
            print("authDataStore loading: \(self.loading)")
        }
    }
    @Published var currentUser: User? = nil {
        didSet {
            self.showLogin = self.currentUser == nil
        }
    }
    @Binding private var baseUrl: String
    @Binding private var token: String
    @Binding private var userId: String
    @Published var showLogin: Bool = true
    let apiService: TwigsApiService
    
    init(_ apiService: TwigsApiService, baseUrl: Binding<String>, token: Binding<String>, userId: Binding<String>) {
        self.apiService = apiService
        self._baseUrl = baseUrl
        self._token = token
        self._userId = userId
    }
    
    func login(server: String, username: String, password: String) async throws {
        self.loading = true
        defer {
            self.loading = false
        }
        self.apiService.baseUrl = server
        // The API Service applies some validation and correcting of the server before returning it so we use that
        // value instead of the original one
        self.baseUrl = self.apiService.baseUrl ?? ""
        var response: LoginResponse
        do {
            response = try await self.apiService.login(username: username, password: password)
        } catch {
            switch error {
            case NetworkError.jsonParsingFailed(let jsonError):
                print(jsonError.localizedDescription)
            default:
                print(error.localizedDescription)
            }
            return
        }
        self.token = response.token
        self.userId = response.userId
        try await self.loadProfile()
    }
    
    func register(server: String, username: String, email: String, password: String, confirmPassword: String) async throws {
        self.loading = true
        defer {
            self.loading = false
        }
        // TODO: Validate other fields as well
        if !password.elementsEqual(confirmPassword) {
            // TODO: Show error message to user
            return
        }
        
        self.apiService.baseUrl = server
        // The API Service applies some validation and correcting of the server before returning it so we use that
        // value instead of the original one
        self.baseUrl = self.apiService.baseUrl ?? ""
        do {
            _ = try await apiService.register(username: username, email: email, password: password)
        } catch {
            switch error {
            case NetworkError.jsonParsingFailed(let jsonError):
                print(jsonError.localizedDescription)
            default:
                print(error.localizedDescription)
            }
            return
        }
        try await self.login(server: server, username: username, password: password)
    }
    
    func loadProfile() async throws {
        self.loading = true
        defer {
            self.loading = false
        }
        if userId == "" {
            throw UserStatus.unauthenticated
        }
        self.currentUser = try await self.apiService.getUser(userId)
    }
}

private let BASE_URL = "BASE_URL"
private let TOKEN = "TOKEN"
private let USER_ID = "USER_ID"

enum UserStatus: Error, Equatable {
    case unauthenticated
    case authenticating
    case failedAuthentication
    case authenticated
    case passwordMismatch
}
