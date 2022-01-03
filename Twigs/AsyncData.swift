//
//  AsyncData.swift
//  Twigs
//
//  Created by William Brawner on 12/31/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

enum AsyncData<Data>: Equatable where Data: Equatable {
    case empty
    case loading
    case error(Error, Data? = nil)
    case success(Data)
    
    static func == (lhs: AsyncData, rhs: AsyncData) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.loading, .loading):
            return true
        case (.error(let lError, let lData), .error(let rError, let rData)):
            return lError.localizedDescription == rError.localizedDescription
                && ((lData == nil && rData == nil) || lData == rData)
        case (.success(let lData), .success(let rData)):
            return lData == rData
        default:
            return false
        }
    }
}
