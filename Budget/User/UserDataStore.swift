import Foundation
import Combine

class UserDataStore: ObservableObject {
    
  // Note: You can combine these into one Result type
  // Result<User, Status>
  var currentUser: User? = nil
  var status: UserStatus = .unauthenticated
  
  func login(username: String, password: String) {
    
    // Changes the status and notifies any observers of the change
    self.status = .authenticating
    self.objectWillChange.send()
    
    // Perform the login
    _ = self.userRepository.login(username: username, password: password)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { (status) in
        switch status {
        case .finished:
          return
          // Do nothing it means the network request just ended
        case .failure(let networkError):
          // Poulate your status with failed authenticating
          self.status = .failedAuthentication
          self.objectWillChange.send()
        }
      }) { (user) in
        self.currentUser = user
        self.objectWillChange.send()
    }
  }
  
  init(_ userRepository: UserRepository) {
    self.userRepository = userRepository
  }
  
  private let userRepository: UserRepository
}

