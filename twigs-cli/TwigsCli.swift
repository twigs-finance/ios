//
//  main.swift
//  twigs-cli
//
//  Created by William Brawner on 1/6/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import ArgumentParser
import TwigsCore

@main
enum TwigsCli {
    static func main() async throws {
        await Twigs.main()
    }
}

protocol AsyncParsableCommand: ParsableCommand {
    mutating func runAsync() async throws
}

extension ParsableCommand {
    static func main() async {
        do {
            var command = try parseAsRoot(nil)
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.runAsync()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }
}

struct Twigs: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "twigs-cli",
        abstract: "A CLI for Twigs, a personal finance application focused on individual and family budgeting",
        version: "1.0.0",
        subcommands: [Twigs.Auth.self]
    )
}

extension Twigs {
    struct Auth: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "commands for authentication with a Twigs server",
            subcommands: [Twigs.Auth.Login.self]
        )
    }
}

extension Twigs.Auth {
    struct Login: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "login with an existing account"
        )
        
        @Option(name: [.short, .long], help: "")
        var token: String = ""
        
        @Option(name: [.short, .long], parsing: SingleValueParsingStrategy.next, help: "the URL to the twigs server")
        var url: String = ""
        
        mutating func runAsync() async throws {
            let config = Config(url: url, token: token)
            // TODO: Check if token was provided, if not check config file
            if let token = await config.token, !token.isEmpty {
                print("using token for login")
                // TODO: Save token to disk
                return
            }
            print("Username:", terminator: " ")
            if let input = readLine(), !input.isEmpty {
                await config.setUsername(input)
            } else {
                throw TwigsErrors.input("ERROR: Username cannot be empty")
            }
            guard let passChars = getpass("Password: ") else {
                throw TwigsErrors.input("ERROR: Unable to read password")
            }
            let password = String(cString: passChars)
            if password.isEmpty {
                throw TwigsErrors.input("ERROR: Password cannot be empty")
            }
            await config.setPassword(password)
            if let username = await config.username, let password = await config.password {
                print("Logging in as \(username) with password \(password)")
                let apiService = TwigsApiService()
                apiService.baseUrl = await config.url
                try await apiService.login(username: username, password: password)
                // TODO: Persist url and token in config file
            }
        }
    }
}

actor Config {
    var url: String? = nil
    var username: String? = nil
    var password: String? = nil
    var token: String? = nil
    
    init(url: String? = nil, token: String? = nil) {
        self.url = url
        self.token = token
    }
    
    func setUsername(_ username: String) {
        self.username = username
    }
    
    func setPassword(_ password: String) {
        self.password = password
    }
}

enum TwigsErrors: Error {
    case input(String)
}
