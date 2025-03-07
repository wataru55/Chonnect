//
//  OnFirstAppear.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/07.
//

import SwiftUI

struct OnFirstAppear: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !self.hasAppeared else { return }
                
                hasAppeared = true
                action()
            }
    }
}

extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppear(action: action))
    }
}
