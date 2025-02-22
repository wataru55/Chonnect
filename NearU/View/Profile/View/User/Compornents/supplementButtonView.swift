//
//  supplementButtonView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/27.
//

import SwiftUI

struct supplementButtonView: View {
    @State private var isShowPopover = false
    let date: Date

    var body: some View {
        VStack {
            Button {
                isShowPopover = true
            } label: {
                Image(systemName: "info.circle")
            }
            .font(.system(size: 20))
            .foregroundStyle(.black)
            .popover(isPresented: $isShowPopover) {
                Tapover(date: date)
                    .presentationCompactAdaptation(PresentationAdaptation.popover)
            }

        }
    }
}

struct Tapover: View {
    let date: Date

    var body: some View {
        VStack(spacing: 0) {
            Text("最後にすれちがった日時：\(formattedDate(date))")
                .font(.footnote)
                .padding()
            
            Divider()
            
            HStack(spacing: 0) {
                Button {
                    print("報告")
                } label: {
                    Text("報告")
                        .foregroundStyle(.black)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.5))
                    .frame(width: 1)
                
                Button {
                    print("ブロック")
                } label: {
                    Text("ブロック")
                        .foregroundStyle(.red)
                        .padding()
                }
                .frame(maxWidth: .infinity)
            }
            .font(.footnote)
    }

    }
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // 日本語ロケール
        formatter.dateFormat = "yyyy/MM/dd (EEE) HH:mm" // 曜日を追加
        return formatter.string(from: date)
    }
}

#Preview {
    supplementButtonView(date: Date())
}
