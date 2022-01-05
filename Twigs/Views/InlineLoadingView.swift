//
//  InlineLoadingView.swift
//  Twigs
//
//  Created by William Brawner on 12/28/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI

struct InlineLoadingView<Content, Data>: View where Content: View, Data: Equatable {
    @Binding var data: AsyncData<Data>
    let action: () async -> Void
    let errorTextLocalizedStringKey: String
    @ViewBuilder
    let successBody: (Data) -> Content
    
    @ViewBuilder
    var body: some View {
        switch self.data {
        case .empty, .loading:
            ActivityIndicator(isAnimating: .constant(true), style: .large)
                .task {
                    await action()
                }
        case .error(let error, _):
            Text(LocalizedStringKey(errorTextLocalizedStringKey))
            Text(error.localizedDescription)
            Button(LocalizedStringKey("action_retry"), action: {
                Task {
                    await action()
                }
            })
        case .success(let data), .editing(let data), .saving(let data):
            successBody(data)
        }
    }
}

#if DEBUG
struct InlineLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        InlineLoadingView(data: .constant(AsyncData<Never>.empty), action: {}, errorTextLocalizedStringKey: "An error ocurred", successBody: { _ in EmptyView() })
    }
}
#endif
