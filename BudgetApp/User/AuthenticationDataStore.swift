import Foundation
import Combine

class AuthenticationDataStore: ObservableObject {
    
    var currentUser: Result<User, UserStatus> = .failure(.unauthenticated) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    func login(username: String, password: String) {
        
        // Changes the status and notifies any observers of the change
        self.currentUser = .failure(.authenticating)
        
        // Perform the login
        _ = self.userRepository.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    return
                // Do nothing it means the network request just ended
                case .failure(let error):
                    switch error {
                    case .jsonParsingFailed(let jsonError):
                        print(jsonError.localizedDescription)
                    default:
                        print(error.localizedDescription)
                    }
                    // Poulate your status with failed authenticating
                    self.currentUser = .failure(.failedAuthentication)
                }
            }) { (user) in
                if let sessionCookie = HTTPCookieStorage.shared.cookies(for: URL(string: SceneDelegate.baseUrl)!)?.first(where: { $0.name == SESSION_KEY }) {
                    UserDefaults.standard.set(sessionCookie.value, forKey: SESSION_KEY)
                }
                self.currentUser = .success(user)
        }
    }
    
    func register(username: String, email: String, password: String, confirmPassword: String) {
        self.currentUser = .failure(.authenticating)
        
        // TODO: Validate other fields as well
        if !password.elementsEqual(confirmPassword) {
            self.currentUser = .failure(.passwordMismatch)
            return
        }
        
        _ = self.userRepository.register(username: username, email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    return
                // Do nothing it means the network request just ended
                case .failure( _):
                    // Poulate your status with failed authenticating
                    self.currentUser = .failure(.failedAuthentication)
                }
            }) { (user) in
                self.currentUser = .success(user)
        }
    }
    
    private func loadFromExistingSession() {
        self.currentUser = .failure(.authenticating)
        
        _ = self.userRepository.getProfile()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
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
        if let sessionKey = UserDefaults.standard.string(forKey: SESSION_KEY) {
            HTTPCookieStorage.shared.setCookie(HTTPCookie(properties: [
                HTTPCookiePropertyKey.name: SESSION_KEY,
                HTTPCookiePropertyKey.value: sessionKey,
                HTTPCookiePropertyKey.domain: URL(string: SceneDelegate.baseUrl)!.host!,
                HTTPCookiePropertyKey.path: "/"
            ])!)
            loadFromExistingSession()
        }
    }
    
    // Needed since the default implementation is currently broken
    let objectWillChange = ObservableObjectPublisher()
    private let userRepository: UserRepository
}

private let SESSION_KEY = "SESSION"

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
        self.currentUser = .success(User(id: 1, username: "test_user", email: "test@localhost.loc", avatar: nil))
    }
}
#endif
