//
//  EdgeSwipeModifier.swift
//  NearU
//
//  Created by  髙橋和 on 2024/12/02.
//

import SwiftUI

struct EdgeSwipe: ViewModifier {
    @Environment(\.dismiss) var dismiss

    private let edgeWidth: Double = UIScreen.main.bounds.width * 0.25
    private let baseDragWidth: Double = 90

    func body(content: Content) -> some View {
        content
            .gesture (
                DragGesture().onChanged { value in
                    if value.startLocation.x < edgeWidth && value.translation.width > baseDragWidth {
                        dismiss()
                    }
                }
            )
    }
}
