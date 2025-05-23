//
//  ViewStateOverlayView.swift
//  NearU
//
//  Created by 高橋和 on 2025/05/20.
//

import SwiftUI

enum ViewState {
    case idle
    case loading
    case success
}

struct ViewStateOverlayView: View {
    @Binding var state: ViewState
    @State private var showSuccess: Bool = true
    
    var body: some View {
        switch state {
        case .loading:
            LoadingView()
            
        case .success:
            SuccessView()
                .opacity(showSuccess ? 1 : 0)
                .onAppear {
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showSuccess = false
                        }
                        // 状態変更は少し遅らせる
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                self.state = .idle
                            }
                        }
                    }
                }
            
        default:
            EmptyView()
        }
    }
}

#Preview {
    ViewStateOverlayView(state: .constant(.idle))
}
