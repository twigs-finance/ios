//
//  RecurringTransactionForm.swift
//  Twigs
//
//  Created by William Brawner on 5/20/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore
import SwiftUI

class RecurringTransactionForm: ObservableObject {
    let apiService: TwigsApiService
    let dataStore: DataStore
    let transaction: TwigsCore.RecurringTransaction?
    let createdBy: String
    let transactionId: String
    @Published var title: String
    @Published var description: String
    @Published var baseFrequencyUnit: String
    @Published var frequencyUnit: FrequencyUnit
    @Published var frequencyCount: String
    @Published var daysOfWeek: Set<DayOfWeek>
    @Published var dayOfMonth: DayOfMonth
    @Published var dayOfYear: DayOfYear
    @Published var amount: String
    @Published var start: Date
    @Published var endCriteria: EndCriteria
    @Published var end: Date?
    @Published var type: TransactionType
    @Published var budgetId: String {
        didSet {
            updateCategories()
        }
    }
    @Published var categoryId: String
    
    @Published var categories: AsyncData<[TwigsCore.Category]> = .empty
    private var cachedCategories: [TwigsCore.Category] = []
    let showDelete: Bool
    
    init(
        dataStore: DataStore,
        createdBy: String,
        budgetId: String,
        categoryId: String? = nil,
        transaction: TwigsCore.RecurringTransaction? = nil
    ) {
        self.apiService = dataStore.apiService
        self.budgetId = budgetId
        self.categoryId = categoryId ?? ""
        self.createdBy = createdBy
        self.dataStore = dataStore
        let baseTransaction = transaction ?? TwigsCore.RecurringTransaction(categoryId: categoryId, createdBy: createdBy, budgetId: budgetId)
        self.transaction = transaction
        self.transactionId = baseTransaction.id
        self.title = baseTransaction.title
        self.description = baseTransaction.description ?? ""
        self.baseFrequencyUnit = baseTransaction.frequency.unit.baseName
        self.frequencyUnit = baseTransaction.frequency.unit
        if case let .weekly(daysOfWeek) = baseTransaction.frequency.unit {
            self.daysOfWeek = daysOfWeek
        } else {
            self.daysOfWeek = Set()
        }
        if case let .monthly(dayOfMonth) = baseTransaction.frequency.unit {
            self.dayOfMonth = dayOfMonth
        } else {
            self.dayOfMonth = DayOfMonth(day: 1)!
        }
        if case let .yearly(dayOfYear) = baseTransaction.frequency.unit {
            self.dayOfYear = dayOfYear
        } else {
            self.dayOfYear = DayOfYear(month: 1, day: 1)!
        }
        self.frequencyCount = String(baseTransaction.frequency.count)
        self.amount = baseTransaction.amountString
        self.start = baseTransaction.start
        self.end = baseTransaction.finish
        if baseTransaction.finish != nil {
            self.endCriteria = .onDate
        } else {
            self.endCriteria = .never
        }
        self.type = baseTransaction.type
        self.showDelete = !baseTransaction.id.isEmpty
    }
    
    func load() async {
        self.categories = .loading
        do {
            let categories = try await apiService.getCategories(budgetId: self.budgetId, expense: nil, archived: false, count: nil, page: nil)
            self.cachedCategories = categories
            updateCategories()
        } catch {
            self.categories = .error(error)
        }
    }
    
    func save() async {
        let amount = Double(self.amount) ?? 0.0
        var frequencyUnit: FrequencyUnit
        switch self.frequencyUnit {
        case .daily:
            frequencyUnit = .daily
        case .weekly(_):
            frequencyUnit = .weekly(self.daysOfWeek)
        case .monthly(_):
            frequencyUnit = .monthly(self.dayOfMonth)
        case .yearly(_):
            frequencyUnit = .yearly(self.dayOfYear)
        }
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self.start)
        let time = Time(hours: components.hour!, minutes: components.minute!, seconds: components.second!)!
        var end: Date? = nil
        if case self.endCriteria = EndCriteria.onDate, let editedEnd = self.end, editedEnd > self.start  {
            end = editedEnd
        }
        await dataStore.saveRecurringTransaction(RecurringTransaction(
            id: transactionId,
            title: title,
            description: description,
            frequency: Frequency(unit: frequencyUnit, count: Int(frequencyCount) ?? 1, time: time)!,
            start: start,
            finish: end,
            amount: Int(amount * 100.0),
            categoryId: categoryId,
            expense: type.toBool(),
            createdBy: createdBy,
            budgetId: budgetId
        ))
    }
    
    func delete() async {
        guard let transaction = self.transaction else {
            return
        }
        await dataStore.deleteRecurringTransaction(transaction)
    }
    
    private func updateCategories() {
        self.categories = .success(cachedCategories.filter {
            $0.expense == self.type.toBool()
        })
    }
}

enum EndCriteria: String, Identifiable, CaseIterable {
    var id: String {
        return self.rawValue
    }
    
    case never = "never"
    case onDate = "onDate"
}
