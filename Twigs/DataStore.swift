//
//  DataStore.swift
//  Twigs
//
//  Created by William Brawner on 5/16/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Collections
import Combine
import Foundation
import TwigsCore

private let LAST_BUDGET = "LAST_BUDGET"

@MainActor
class DataStore : ObservableObject {
    let apiService: TwigsApiService
    @Published var budgets: AsyncData<[Budget]> = .empty
    @Published var budget: AsyncData<Budget> = .empty {
        didSet {
            if case let .success(budget) = self.budget {
                UserDefaults.standard.set(budget.id, forKey: LAST_BUDGET)
                self.showBudgetSelection = false
                self.editingBudget = false
            }
            if case .editing(_) = self.budget {
                self.editingBudget = true
            }
        }
    }
    @Published var overview: AsyncData<BudgetOverview> = .empty
    @Published var showBudgetSelection: Bool = false
    @Published var editingBudget: Bool = false
    @Published var editingCategory: Bool = false
    @Published var editingRecurringTransaction: Bool = false

    var currentUserId: String? {
        get {
            if case let .success(currentUser) = self.currentUser {
                return currentUser.id
            } else {
                return nil
            }
        }
    }
    
    var budgetId: String? {
        get {
            if case let .success(budget) = self.budget {
                return budget.id
            } else {
                return nil
            }
        }
    }
    
    var categoryId: String? {
        get {
            if case let .success(category) = self.category {
                return category.id
            } else {
                return nil
            }
        }
    }

    init(
        _ apiService: TwigsApiService
    ) {
        self.apiService = apiService
        self.baseUrl = UserDefaults.standard.string(forKey: KEY_BASE_URL) ?? ""
        self.apiService.baseUrl = baseUrl
        self.token = UserDefaults.standard.string(forKey: KEY_TOKEN)
        self.userId = UserDefaults.standard.string(forKey: KEY_USER_ID)
    }
    
    func getBudgets(count: Int? = nil, page: Int? = nil) async {
        // TODO: Find some way to extract this to a generic function
        self.budgets = .loading
        do {
            let budgets = try await self.apiService.getBudgets(count: count, page: page).sorted(by: { $0.name < $1.name })
            self.budgets = .success(budgets)
            if budgets.isEmpty {
                showBudgetSelection = true
            }
            if self.budget != .empty {
                return
            }
            if let id = UserDefaults.standard.string(forKey: LAST_BUDGET), let lastBudget = budgets.first(where: { $0.id == id }) {
                await self.selectBudget(lastBudget)
            } else {
                if let budget = budgets.first {
                    await self.selectBudget(budget)
                }
            }
        } catch {
            self.budgets = .error(error)
            showBudgetSelection = true
        }
    }
    
    func newBudget() {
        self.budget = .editing(Budget(id: "", name: "", description: "", currencyCode: ""))
    }
    
    func save(_ budget: Budget) async {
        self.budget = .saving(budget)
        do {
            var savedBudget: Budget
            if budget.id != "" {
                savedBudget = try await self.apiService.updateBudget(budget)
            } else {
                savedBudget = try await self.apiService.newBudget(budget)
            }
            await self.selectBudget(savedBudget)
            if case let .success(budgets) = self.budgets {
                var updatedBudgets = budgets.filter(withoutId: budget.id)
                updatedBudgets.append(savedBudget)
                self.budgets = .success(updatedBudgets.sorted(by: { $0.name < $1.name }))
            }
        } catch {
            self.budget = .error(error, budget)
        }
    }
    
    func deleteBudget() async {
        guard case let .editing(budget) = self.budget, budget.id != "" else {
            return
        }
        self.budget = .loading
        do {
            try await self.apiService.deleteBudget(budget.id)
            await self.selectBudget(nil)
            if case let .success(budgets) = self.budgets {
                self.budgets = .success(budgets.filter(withoutId: budget.id))
            }
        } catch {
            self.budget = .error(error, budget)
        }
    }
    
    func cancelEditBudget() async {
        guard case let .success(budgets) = self.budgets else {
            return
        }
        if budgets.isEmpty {
            // Prevent the user from exiting the new budget flow if they haven't created any budgets yet
            return
        }
        guard case let .editing(budget) = self.budget else {
            return
        }
        await self.selectBudget(budget)
    }
    
    func loadOverview(_ budget: Budget) async {
        self.overview = .loading
        do {
            let budgetBalance = try await self.apiService.sumTransactions(budgetId: budget.id, categoryId: nil, from: nil, to: nil)
            let categories = try await self.apiService.getCategories(budgetId: budget.id, expense: nil, archived: false, count: nil, page: nil)
            var budgetOverview = BudgetOverview(budget: budget, balance: budgetBalance.balance)
            try await withThrowingTaskGroup(of: (TwigsCore.Category, BalanceResponse).self) { group in
                for category in categories {
                    group.addTask {
                        return (category, try await self.apiService.sumTransactions(budgetId: nil, categoryId: category.id, from: nil, to: nil))
                    }
                }

                for try await (category, response) in group {
                    if category.expense {
                        budgetOverview.expectedExpenses += category.amount
                    } else {
                        budgetOverview.expectedIncome += category.amount
                    }
                    
                    if category.expense {
                        budgetOverview.actualExpenses += abs(response.balance)
                    } else {
                        budgetOverview.actualIncome += response.balance
                    }
                }
            }
            self.overview = .success(budgetOverview)
        } catch {
            self.overview = .error(error)
        }
    }
    
    func selectBudget(_ budget: Budget?) async {
        if let budget = budget {
            self.budget = .success(budget)
            await loadOverview(budget)
            await getTransactions()
            await getCategories(budgetId: budget.id, expense: nil, archived: nil, count: nil, page: nil)
            await getRecurringTransactions()
        } else {
            self.budget = .empty
            self.transactions = .empty
            self.categories = .empty
            self.recurringTransactions = .empty
        }
    }
    
    func editBudget() {
        guard case let .success(budget) = self.budget else {
            return
        }
        self.budget = .editing(budget)
    }

    @Published var categories: AsyncData<[TwigsCore.Category]> = .empty
    @Published var category: AsyncData<TwigsCore.Category> = .empty {
        didSet {
            if case let .success(category) = self.category {
                self.selectedCategory = category
            } else if case .empty = self.category {
                self.selectedCategory = nil
            }
        }
    }
    @Published var selectedCategory: TwigsCore.Category? = nil
    
    func getCategories() async {
        guard case let .success(budget) = self.budget else {
            return
        }
        await self.getCategories(budgetId: budget.id)
    }
    
    func getCategories(budgetId: String, expense: Bool? = nil, archived: Bool? = false, count: Int? = nil, page: Int? = nil) async {
        self.categories = .loading
        do {
            let categories = try await apiService.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page)
            self.categories = .success(categories)
        } catch {
            self.categories = .error(error)
        }
    }
        
    func save(_ category: TwigsCore.Category) async {
        self.category = .loading
        do {
            var savedCategory: TwigsCore.Category
            if category.id != "" {
                savedCategory = try await self.apiService.updateCategory(category)
            } else {
                savedCategory = try await self.apiService.createCategory(category)
            }
            self.category = .success(savedCategory)
            self.editingCategory = false
            if case let .success(categories) = self.categories {
                var updatedCategories = categories.filter(withoutId: category.id)
                updatedCategories.append(savedCategory)
                self.categories = .success(updatedCategories.sorted(by: { $0.title < $1.title }))
            }
        } catch {
            self.category = .error(error, category)
        }
    }
    
    func delete(_ category: TwigsCore.Category) async {
        self.category = .loading
        do {
            try await self.apiService.deleteCategory(category.id)
            self.category = .empty
            self.editingCategory = false
            if case let .success(categories) = self.categories {
                self.categories = .success(categories.filter(withoutId: category.id))
            }
        } catch {
            self.category = .error(error, category)
        }
    }
    
    func edit(_ category: TwigsCore.Category) async {
        self.editingCategory = true
        self.category = .editing(category)
    }
    
    func cancelEditCategory() {
        self.editingCategory = false
        if let category = self.selectedCategory {
            self.category = .success(category)
        } else {
            self.category = .empty
        }
    }

    func clearSelectedCategory() {
        self.category = .empty
    }

    @Published var recurringTransactions: AsyncData<[RecurringTransaction]> = .empty
    @Published var recurringTransaction: AsyncData<RecurringTransaction> = .empty {
        didSet {
            if case let .success(transaction) = self.recurringTransaction {
                self.selectedRecurringTransaction = transaction
                self.editingRecurringTransaction = false
            } else if case .empty = recurringTransaction {
                self.selectedRecurringTransaction = nil
                self.editingRecurringTransaction = false
            } else if case .editing(_) = self.recurringTransaction {
                self.editingRecurringTransaction = true
            }
        }
    }
    @Published var selectedRecurringTransaction: RecurringTransaction? = nil
        
    func getRecurringTransactions() async {
        guard case let .success(budget) = self.budget else {
            return
        }
        self.recurringTransactions = .loading
        do {
            let transactions = try await self.apiService.getRecurringTransactions(budget.id)
            self.recurringTransactions = .success(transactions.sorted(by: { $0.title < $1.title }))
        } catch {
            self.recurringTransactions = .error(error)
        }
    }
    
    func newRecurringTransaction() {
        guard case let .success(user) = self.currentUser else {
            return
        }
        guard case let .success(budget) = self.budget else {
            return
        }
        self.recurringTransaction = .editing(RecurringTransaction(createdBy: user.id, budgetId: budget.id))
    }
    
    func edit(_ transaction: RecurringTransaction) async {
        self.recurringTransaction = .editing(transaction)
    }
    
    func cancelEditRecurringTransaction() {
        guard case let .editing(rt) = self.recurringTransaction else {
            return
        }
        if !rt.id.isEmpty {
            self.recurringTransaction = .success(rt)
        } else {
            self.recurringTransaction = .empty
        }
    }
    
    func saveRecurringTransaction(_ transaction: RecurringTransaction) async {
        self.recurringTransaction = .loading
        do {
            var savedTransaction: RecurringTransaction
            if (transaction.id != "") {
                savedTransaction = try await self.apiService.updateRecurringTransaction(transaction)
            } else {
                savedTransaction = try await self.apiService.createRecurringTransaction(transaction)
            }
            if transaction.id != "" {
                self.recurringTransaction = .success(savedTransaction)
            } else {
                self.recurringTransaction = .empty
            }
            if case var .success(transactions) = self.recurringTransactions {
                transactions = transactions.filter(withoutId: savedTransaction.id)
                transactions.append(savedTransaction)
                self.recurringTransactions = .success(transactions.sorted(by: { $0.title < $1.title }))
            }
        } catch {
            self.recurringTransactions = .error(error)
        }
    }
    
    func deleteRecurringTransaction(_ transaction: RecurringTransaction) async {
        self.recurringTransaction = .loading
        do {
            try await self.apiService.deleteRecurringTransaction(transaction.id)
            self.recurringTransaction = .empty
            if case let .success(transactions) = self.recurringTransactions {
                self.recurringTransactions = .success(transactions.filter(withoutId: transaction.id))
            }
        } catch {
            self.recurringTransaction = .error(error, transaction)
        }
    }
    
    func clearSelectedRecurringTransaction() {
        self.recurringTransaction = .empty
    }

    @Published var transactions: AsyncData<OrderedDictionary<String, [Transaction]>> = .empty
    @Published var transaction: AsyncData<Transaction> = .empty {
        didSet {
            if case let .success(transaction) = self.transaction {
                self.selectedTransaction = transaction
            } else if case .empty = self.transaction {
                self.selectedTransaction = nil
            }
        }
    }
    @Published var selectedTransaction: Transaction? = nil
    
    func getTransactions() async {
        guard  let budgetId = self.budgetId else {
            self.transactions = .error(NetworkError.unknown)
            return
        }
        self.transactions = .loading
        do {
            var categoryIds: [String] = []
            if let categoryId = categoryId {
                categoryIds.append(categoryId)
            }
            let transactions = try await self.apiService.getTransactions(
                budgetIds: [budgetId],
                categoryIds: categoryIds,
                from: Date.firstOfMonth,
                to: nil,
                count: nil,
                page: nil
            )
            let groupedTransactions = OrderedDictionary<String,[Transaction]>(grouping: transactions, by: { $0.date.toLocaleString() })
            self.transactions = .success(groupedTransactions)
        } catch {
            self.transactions = .error(error)
        }
    }
    
    func saveTransaction(_ transaction: Transaction) async {
        self.transaction = .saving(transaction)
        do {
            var savedTransaction: Transaction
            if (transaction.id != "") {
                savedTransaction = try await self.apiService.updateTransaction(transaction)
            } else {
                savedTransaction = try await self.apiService.createTransaction(transaction)
            }
            if transaction.id != "" {
                self.transaction = .success(savedTransaction)
            } else {
                self.transaction = .empty
            }
            await getTransactions()
        } catch {
            self.transaction = .error(error, transaction)
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async {
        self.transaction = .loading
        do {
            try await self.apiService.deleteTransaction(transaction.id)
            self.transaction = .empty
        } catch {
            self.transaction = .error(error, transaction)
        }
    }
    
    func newTransaction() {
        var budgetId = ""
        if case let .success(budget) = self.budget {
            budgetId = budget.id
        }
        var categoryId: String? = nil
        if case let .success(category) = self.category {
            categoryId = category.id
        }
        var createdBy = ""
        if case let .success(user) = self.currentUser {
            createdBy = user.id
        }
        self.transaction = .editing(TwigsCore.Transaction(categoryId: categoryId, createdBy: createdBy, budgetId: budgetId))
    }
    
    func editTransaction(_ transaction: Transaction) {
        self.transaction = .editing(transaction)
    }

    func cancelEditTransaction() {
        if let transaction = self.selectedTransaction {
            self.transaction = .success(transaction)
        } else {
            self.transaction = .empty
        }
    }
    
    func clearSelectedTransaction() {
        self.transaction = .empty
    }
    
    @Published var currentUser: AsyncData<User> = .empty {
        didSet {
            switch currentUser {
            case .empty, .loading:
                self.showLogin = true
            case .error(_, let user):
                self.showLogin = user == nil
            default:
                self.showLogin = false
            }
        }
    }
    
    private let KEY_BASE_URL = "BASE_URL"
    private let KEY_TOKEN = "TOKEN"
    private let KEY_USER_ID = "USER_ID"

    @Published var baseUrl: String {
        didSet {
            self.apiService.baseUrl = baseUrl
            UserDefaults.standard.set(baseUrl, forKey: KEY_BASE_URL)
        }
    }
    @Published var token: String? {
        didSet {
            self.apiService.token = token
            UserDefaults.standard.set(token, forKey: KEY_TOKEN)
        }
    }
    @Published var userId: String? {
        didSet {
            UserDefaults.standard.set(userId, forKey: KEY_USER_ID)
        }
    }
    @Published var showLogin: Bool = true
    
    func clearUserError() {
        self.currentUser = .empty
    }
    
    func login(username: String, password: String) async {
        if baseUrl.isEmpty {
            self.currentUser = .error(NetworkError.invalidUrl)
            return
        }
        self.currentUser = .loading
        do {
            let response = try await self.apiService.login(username: username, password: password)
            self.token = response.token
            self.userId = response.userId
            await self.loadProfile()
        } catch {
            switch error {
            case NetworkError.jsonParsingFailed(let jsonError):
                print(jsonError.localizedDescription)
            default:
                print(error.localizedDescription)
            }
            self.currentUser = .error(error)
        }
    }
    
    func register(username: String, email: String, password: String, confirmPassword: String) async {
        if baseUrl.isEmpty {
            self.currentUser = .error(NetworkError.invalidUrl)
            return
        }
        if username.isEmpty {
            self.currentUser = .error(UsernameError.empty)
            return
        }
        if !email.isEmpty && (!email.contains("@") || !email.contains(".")) {
            self.currentUser = .error(EmailError.invalid)
            return
        }
        if password.isEmpty {
            self.currentUser = .error(PasswordError.empty)
            return
        }
        if !password.elementsEqual(confirmPassword) {
            self.currentUser = .error(PasswordError.notMatching)
            return
        }
        do {
            _ = try await apiService.register(username: username, email: email, password: password)
        } catch {
            switch error {
            case NetworkError.jsonParsingFailed(let jsonError):
                print(jsonError.localizedDescription)
            default:
                print(error.localizedDescription)
            }
            self.currentUser = .error(error)
            return
        }
        await self.login(username: username, password: password)
    }
    
    func logout() {
        self.budgets = .empty
        self.budget = .empty
        self.overview = .empty
        self.categories = .empty
        self.category = .empty
        self.transactions = .empty
        self.transaction = .empty
        self.recurringTransactions = .empty
        self.recurringTransaction = .empty
        self.selectedRecurringTransaction = nil
        self.selectedCategory = nil
        self.selectedTransaction = nil
        self.currentUser = .empty
        self.user = .empty
        self.token = nil
        UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
        UserDefaults.standard.removeObject(forKey: KEY_USER_ID)
    }
    
    func loadProfile() async {
        guard let userId = self.userId, !userId.isEmpty else {
            return
        }
        do {
            let user = try await self.apiService.getUser(userId)
            self.currentUser = .success(user)
            await getBudgets()
        } catch {
            self.currentUser = .error(error)
        }
    }
    
    func updateUsername(_ username: String) async -> UsernameError? {
        guard case let .success(current) = self.currentUser else {
            return .unknown
        }
        self.currentUser = .saving(current)
        do {
            let updated = try await self.apiService.updateUser(current.copy(username: username))
            self.currentUser = .success(updated)
            return nil
        } catch {
            self.currentUser = .error(error, current)
            return .unavailable
        }
    }
    
    func updateEmail(_ email: String) async -> EmailError? {
        guard case let .success(current) = self.currentUser else {
            return .unknown
        }
        if !email.isEmpty && (!email.contains("@") || !email.contains(".")) {
            return .invalid
        }
        self.currentUser = .saving(current)
        do {
            let updated = try await self.apiService.updateUser(current.copy(email: email))
            self.currentUser = .success(updated)
            return nil
        } catch {
            self.currentUser = .error(error, current)
            return .unavailable
        }
    }
    
    func updatePassword(_ password: String, confirmPassword: String) async -> PasswordError? {
        guard case let .success(current) = self.currentUser else {
            return .unknown
        }
        if password != confirmPassword {
            return .notMatching
        }
        self.currentUser = .saving(current)
        do {
            let updated = try await self.apiService.updateUser(current.copy(password: password))
            self.currentUser = .success(updated)
            return nil
        } catch {
            self.currentUser = .error(error, current)
            return .unknown
        }
    }

    func saveUser(_ user: User) async -> Bool {
        guard case let .success(current) = self.currentUser else {
            return false
        }
        self.currentUser = .saving(current)
        do {
            let updated = try await self.apiService.updateUser(user)
            self.currentUser = .success(updated)
            return true
        } catch {
            self.currentUser = .error(error, current)
            return false
        }
    }

    @Published var user: AsyncData<User> = .empty

    func getUser(_ id: String) async {
        do {
            let user = try await self.apiService.getUser(id)
            self.user = .success(user)
        } catch {
            self.currentUser = .error(error)
        }
    }
}

enum UsernameError: String, Error {
    case empty = "username_cannot_be_empty"
    case unavailable = "username_taken"
    case unknown = "unknown_error"
}

enum EmailError: String, Error {
    case invalid = "email_invalid"
    case unavailable = "email_taken"
    case unknown = "unknown_error"
}

enum PasswordError: String, Error {
    case empty = "password_cannot_be_empty"
    case notMatching = "passwords_dont_match"
    case unknown = "unknown_error"
}
