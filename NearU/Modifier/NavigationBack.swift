//
//  NavigationBack.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/17.
//

import SwiftUI

struct NavigationBack: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.black)
                    }
                }
            }
            .modifier(EdgeSwipe())
    }
}

extension View {
    func navigationBack() -> some View {
        self.modifier(NavigationBack())
    }
}
