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
            VStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.2)
                Text("Loading...")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    LoadingView()
}
