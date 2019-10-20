//
//  ProgressView.swift
//  BudgetApp
//
//  Created by Billy Brawner on 10/20/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    @Binding var value: CGFloat
    var maxValue: CGFloat = 100.0
    var progressTintColor: Color = .blue
    var progressBarHeight: CGFloat = 20
    var progressBarCornerRadius: CGFloat = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.1)
                Rectangle()
                    .frame(
                        minWidth: 0,
                        idealWidth: self.getProgressBarWidth(geometry: geometry),
                        maxWidth: self.getProgressBarWidth(geometry: geometry)
                )
                    .opacity(0.5)
                    .background(self.progressTintColor)
                    .animation(.default)
            }.frame(height: self.progressBarHeight)
                .cornerRadius(self.progressBarCornerRadius)
        }
    }
    
    private func getProgressBarWidth(geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        return frame.size.width * (value / maxValue)
    }
}


struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: .constant(50.0), maxValue: 100.0, progressTintColor: .red)
    }
}
