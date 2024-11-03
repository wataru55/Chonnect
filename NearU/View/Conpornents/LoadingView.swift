//
//  LoadingView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/03.
//

import SwiftUI

struct LoadingView: View {

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.2)
                Text("処理中です...")
                    .foregroundColor(.black)
                    .font(.headline)
            }
            .padding()
            .background() {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    LoadingView()
}
