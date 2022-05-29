//
//  RecurringTransactionFormView.swift
//  Twigs
//
//  Created by William Brawner on 5/18/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct RecurringTransactionFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var transactionForm: RecurringTransactionForm
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            switch self.dataStore.recurringTransaction {
            case .loading:
                EmbeddedLoadingView()
            default:
                Form {
                    Section {
                        TextField(LocalizedStringKey("prompt_name"), text: $transactionForm.title)
                            .textInputAutocapitalization(.words)
                        TextField(LocalizedStringKey("prompt_description"), text: $transactionForm.description)
                            .textInputAutocapitalization(.sentences)
                        TextField(LocalizedStringKey("prompt_amount"), text: $transactionForm.amount)
                            .keyboardType(.decimalPad)
                        Picker(LocalizedStringKey("prompt_type"), selection: $transactionForm.type) {
                            ForEach(TransactionType.allCases) { type in
                                Text(type.localizedKey)
                            }
                        }
                    }
                    Section {
                        HStack {
                            Text("Repeat every")
                            TextField("count", text: $transactionForm.frequencyCount)
                                .keyboardType(.decimalPad)
                        }
                        Picker(selection: self.$transactionForm.baseFrequencyUnit.animation(), content: {
                            ForEach(FrequencyUnit.allCases) {
                                Text(LocalizedStringKey($0.baseName)).tag($0.baseName)
                            }
                        }, label: {
                            Text("frequency")
                        })
                            .pickerStyle(.segmented)
                        FrequencyPickerView(
                            frequencyUnit: $transactionForm.baseFrequencyUnit,
                            daysOfWeek: $transactionForm.daysOfWeek,
                            dayOfMonth: $transactionForm.dayOfMonth,
                            dayOfYear: $transactionForm.dayOfYear
                        )
                    }
                    Section(footer: Text("note_end_optional")) {
                        DatePicker(selection: $transactionForm.start, label: { Text(LocalizedStringKey("prompt_start")) })
                        Picker(LocalizedStringKey("prompt_end"), selection: $transactionForm.endCriteria.animation()) {
                            ForEach(EndCriteria.allCases) { criteria in
                                Text(LocalizedStringKey(criteria.rawValue)).tag(criteria)
                            }
                        }
                        if case .onDate = transactionForm.endCriteria {
                            DatePicker(
                                "",
                                selection: Binding<Date>(get: {transactionForm.end ?? Date()}, set: {transactionForm.end = $0})
                            )
                        }
                    }
                    Section {
                        CategoryPicker(categories: $transactionForm.categories, categoryId: $transactionForm.categoryId)
                    }
                    if transactionForm.showDelete {
                        Button(action: {
                            self.showingAlert = true
                        }) {
                            Text(LocalizedStringKey("delete"))
                                .foregroundColor(.red)
                        }
                        .alert(isPresented:$showingAlert) {
                            Alert(
                                title: Text(LocalizedStringKey("confirm_delete")),
                                message: Text(LocalizedStringKey("cannot_undo")),
                                primaryButton: .destructive(
                                    Text(LocalizedStringKey("delete")),
                                    action: { Task { await transactionForm.delete() }}
                                ),
                                secondaryButton: .cancel()
                            )
                        }
                    } else {
                        EmptyView()
                    }
                }.environmentObject(transactionForm)
                    .task {
                        await transactionForm.load()
                    }
                    .navigationTitle(transactionForm.transactionId.isEmpty ? "add_recurring_transaction" : "edit_recurring_transaction")
                    .navigationBarItems(
                        leading: Button("cancel", action: { dataStore.cancelEditRecurringTransaction() }),
                        trailing: Button("save", action: {
                            Task {
                                await transactionForm.save()
                            }
                        })
                    )
            }
        }
    }
}

struct FrequencyPickerView: View {
    @Binding var frequencyUnit: String
    @Binding var daysOfWeek: Set<DayOfWeek>
    @Binding var dayOfMonth: DayOfMonth
    @Binding var dayOfYear: DayOfYear

    @ViewBuilder
    var body: some View {
        switch frequencyUnit {
        case "week":
            WeeklyFrequencyPicker(selection: $daysOfWeek)
        case "month":
            MonthlyFrequencyPicker(dayOfMonth: $dayOfMonth)
        case "year":
            YearlyFrequencyPicker(dayOfYear: $dayOfYear)
        default:
            EmptyView()
        }
    }
}

struct RecurringTransactionFormView_Previews: PreviewProvider {
    static var dataStore = DataStore(TwigsInMemoryCacheService())
    static var previews: some View {
        RecurringTransactionFormView(transactionForm: RecurringTransactionForm(
            dataStore: dataStore,
            createdBy: MockUserRepository.currentUser.id,
            budgetId: MockBudgetRepository.budget.id
        )).environmentObject(dataStore)
    }
}
