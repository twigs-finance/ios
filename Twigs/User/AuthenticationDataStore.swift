import Foundation
import Combine
import SwiftUI

class AuthenticationDataStore: ObservableObject {
    private var currentRequest: AnyCancellable? = nil
    @Published var currentUser: Result<User, UserStatus> = .failure(.unauthenticated)
    var showLogin: Bool {
        get {
            switch currentUser {
            case .success(_):
                print("Authenticated")
                return false
            default:
                print("Unauthenticated")
                return true
            }
        }
        set { }
    }

    func login(server: String, username: String, password: String) {
        // Changes the status and notifies any observers of the change
        self.currentUser = .failure(.authenticating)
        // Perform the login
        self.userRepository.setServer(server)
        currentRequest = self.userRepository.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    return
                case .failure(let error):
                    self.currentRequest = nil
                    switch error {
                    case .jsonParsingFailed(let jsonError):
                        print(jsonError.localizedDescription)
                    default:
                        print(error.localizedDescription)
                    }
                    self.currentUser = .failure(.failedAuthentication)
                }
            }) { (session) in
                UserDefaults.standard.set(session.token, forKey: TOKEN)
                UserDefaults.standard.set(session.userId, forKey: USER_ID)
                self.loadProfile()
        }
    }
    
    func register(username: String, email: String, password: String, confirmPassword: String) {
        self.currentUser = .failure(.authenticating)
        
        // TODO: Validate other fields as well
        if !password.elementsEqual(confirmPassword) {
            self.currentUser = .failure(.passwordMismatch)
            return
        }
        
        currentRequest = self.userRepository.register(username: username, email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    return
                case .failure( _):
                    self.currentUser = .failure(.failedAuthentication)
                }
            }) { (user) in
                self.currentUser = .success(user)
        }
    }
    
    private func loadProfile() {
        guard let userId = UserDefaults.standard.string(forKey: USER_ID) else {
            self.currentUser = .failure(.unauthenticated)
            return
        }
        guard let token = UserDefaults.standard.string(forKey: TOKEN) else {
            self.currentUser = .failure(.unauthenticated)
            return
        }
        self.currentUser = .failure(.authenticating)
        self.userRepository.setToken(token)
        currentRequest = self.userRepository.getUser(userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(_):
                    self.currentUser = .failure(.unauthenticated)
                }
            }) { (user) in
                self.currentUser = .success(user)
        }
    }
    
    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
        if UserDefaults.standard.string(forKey: TOKEN) != nil {
            loadProfile()
        }
    }
    
    private let userRepository: UserRepository
}

private let TOKEN = "TOKEN"
private let USER_ID = "USER_ID"

enum UserStatus: Error, Equatable {
    case unauthenticated
    case authenticating
    case failedAuthentication
    case authenticated
    case passwordMismatch // Passwords don't match
}

#if DEBUG
class MockAuthenticationDataStore: AuthenticationDataStore {
    override init(_ userRepository: UserRepository) {
        super.init(userRepository)
        self.currentUser = .success(User(id: "1", username: "test_user", email: "test@localhost.loc", avatar: nil))
    }
}
#endif
