//
//  SuccessView.swift
//  NearU
//
//  Created by 高橋和 on 2025/05/20.
//

import SwiftUI

struct SuccessView: View {
    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    
                Text("完了！！")
                    .font(.footnote)
            }
            .padding(12)
            .foregroundStyle(.green)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.green.opacity(0.2))
            }
        }
    }
}

#Preview {
    SuccessView()
}
