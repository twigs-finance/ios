//
//  AsyncObservableObject.swift
//  Twigs
//
//  Created by William Brawner on 12/24/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore

class AsyncObservableObject: ObservableObject {
    @Published var loading: Bool = false
    
    func load<T>(block: () async throws -> T) async throws -> T {
        self.loading = true
        defer {
            self.loading = false
        }
        do {
            return try await block()
        } catch {
            switch error {
            case NetworkError.jsonParsingFailed(let wrappedError):
                print("\(wrappedError.localizedDescription)")
            default:
                print("\(error.localizedDescription)")
            }
            throw error
        }
    }
}
