import Foundation
import Combine

class UserDataStore: ObservableObject {
    
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
    
    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    // Needed since the default implementation is currently broken
    let objectWillChange = ObservableObjectPublisher()
    private let userRepository: UserRepository
}

enum UserStatus: Error, Equatable {
    case unauthenticated
    case authenticating
    case failedAuthentication
    case authenticated
    case passwordMismatch // Passwords don't match
}
