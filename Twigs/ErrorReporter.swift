//
//  ErrorReporter.swift
//  Twigs
//
//  Created by William Brawner on 9/9/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation

protocol ErrorReporter {
    func reportError(error: Error)
}

class LoggingErrorReporter: ErrorReporter {
    func reportError(error: Error) {
        print(error)
    }
}
