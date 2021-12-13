//
//  RecurringTransaction.swift
//  Twigs
//
//  Created by William Brawner on 12/3/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

struct RecurringTransaction: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String?
    let frequency: Frequency
    let start: Date
    let end: Date?
    let amount: Int
    let categoryId: String?
    let expense: Bool
    let createdBy: String
    let budgetId: String
}

struct Frequency: Hashable, Codable, CustomStringConvertible {
    let unit: FrequencyUnit
    let count: Int
    let time: Time
    
    init?(unit: FrequencyUnit, count: Int, time: Time) {
        if count < 1 {
            return nil
        }
        self.unit = unit
        self.count = count
        self.time = time
    }
    
    init?(from string: String) {
        let parts = string.split(separator: ";")
        guard let count = Int(parts[1]) else {
            return nil
        }
        var timeIndex = 3
        switch parts[0] {
        case "D":
            self.unit = .daily
            timeIndex = 2
        case "W":
            let daysOfWeek = parts[2].split(separator: ",").compactMap { dayOfWeek in
                DayOfWeek(rawValue: String(dayOfWeek))
            }
            if daysOfWeek.isEmpty {
                return nil
            }
            self.unit = .weekly(Set(daysOfWeek))
        case "M":
            guard let dayOfMonth = DayOfMonth(from: String(parts[2])) else {
                return nil
            }
            self.unit = .monthly(dayOfMonth)
        case "Y":
            guard let dayOfYear = DayOfYear(from: String(parts[2])) else {
                return nil
            }
            self.unit = .yearly(dayOfYear)
        default:
            return nil
        }
        guard let time = Time(from: String(parts[timeIndex])) else {
            return nil
        }
        self.time = time
        self.count = count
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let frequencyString = try container.decode(String.self)
        self.init(from: frequencyString)!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    var description: String {
        // TODO: Make the backend representation of this more sensible and then use this
        // return [unit.description, count.description, time.description].joined(separator: ";")
        let unitParts = "\(unit)".split(separator: ";")
        if unitParts.count == 1 {
            return [unitParts[0].description, count.description, time.description].joined(separator: ";")
        } else{
            return [unitParts[0].description, count.description, unitParts[1].description, time.description].joined(separator: ";")
        }
    }

    var naturalDescription: String {
        return unit.format(count: count, time: time)
    }
}

enum FrequencyUnit: Hashable, CustomStringConvertible {
    case daily
    case weekly(Set<DayOfWeek>)
    case monthly(DayOfMonth)
    case yearly(DayOfYear)
    
    var description: String {
        switch self {
        case .daily:
            return "D"
        case .weekly(let daysOfWeek):
            return String(format: "W;%s", daysOfWeek.map { $0.rawValue }.joined(separator: ","))
        case .monthly(let dayOfMonth):
            return String(format: "M;%s", dayOfMonth.description)
        case .yearly(let dayOfYear):
            return String(format: "Y;%s", dayOfYear.description)
        }
    }
    
    func format(count: Int, time: Time) -> String {
        switch self {
        case .daily:
            return String(localized: "Every \(count) day(s) at \(time.description)")
        case .weekly(let daysOfWeek):
            return String(localized: "Every \(count) week(s) on \(daysOfWeek.description) at \(time.description)")
        case .monthly(let dayOfMonth):
            return String(localized: "Every \(count) month(s) on the \(dayOfMonth.description) at \(time.description)")
        case .yearly(let dayOfYear):
            return String(localized: "Every \(count) year(s) on \(dayOfYear.description) at \(time.description)")
        }
    }
}

struct Time: Hashable, CustomStringConvertible {
    let hours: Int
    let minutes: Int
    let seconds: Int
    
    init?(hours: Int, minutes: Int, seconds: Int) {
        if hours < 0 || hours > 23 {
            return nil
        }
        if minutes < 0 || minutes > 59 {
            return nil
        }
        if seconds < 0 || seconds > 59 {
            return nil
        }
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    init?(from string: String) {
        let parts = string.split(separator: ":").compactMap {
            Int($0)
        }
        if parts.count != 3 {
            return nil
        }
        self.init(hours: parts[0], minutes: parts[1], seconds: parts[2])
    }
    
    var description: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

enum DayOfMonth: Hashable, CustomStringConvertible {
    case positional(Position, DayOfWeek)
    case fixed(Int)
    init?(position: Position, dayOfWeek: DayOfWeek) {
        if position == .day {
            return nil
        }
        self = .positional(position, dayOfWeek)
    }
    
    init?(day: Int) {
        if day < 1 || day > 31 {
            return nil
        }
        self = .fixed(day)
    }
    
    init?(from string: String) {
        let parts = string.split(separator: "-")
        guard let position = Position.init(rawValue: String(parts[0])) else {
            return nil
        }
        if position == .day {
            guard let day = Int(parts[1]) else {
                return nil
            }
            self = .fixed(day)
        } else {
            guard let dayOfWeek = DayOfWeek(rawValue: String(parts[1])) else {
                return nil
            }
            self = .positional(position, dayOfWeek)
        }
    }
    
    var description: String {
        switch self {
        case .positional(let position, let dayOfWeek):
            return "\(position)-\(dayOfWeek)"
        case .fixed(let day):
            return "\(Position.day)-\(day)"
        }
    }
}

enum Position: String, Hashable {
    case day = "DAY"
    case first = "FIRST"
    case second = "SECOND"
    case third = "THIRD"
    case fourth = "FOURTH"
    case last = "LAST"
}

enum DayOfWeek: String, Hashable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}

struct DayOfYear: Hashable, CustomStringConvertible {
    let month: Int
    let day: Int
    
    init?(month: Int, day: Int) {
        var maxDay: Int
        switch month {
        case 2:
            maxDay = 29;
            break;
        case 4, 6, 9, 11:
            maxDay = 30;
            break;
        default:
            maxDay = 31;
        }
        if day < 1 || day > maxDay {
            return nil
        }
        if month < 1 || month > 12 {
            return nil
        }
        self.day = day
        self.month = month
    }
    
    init?(from string: String) {
        let parts = string.split(separator: "-").compactMap {
            Int($0)
        }
        if parts.count < 2 {
            return nil
        }
        self.init(month: parts[0], day: parts[1])
    }
    
    var description: String {
        return String(format: "%02d-%02d", self.month, self.day)
    }
}
