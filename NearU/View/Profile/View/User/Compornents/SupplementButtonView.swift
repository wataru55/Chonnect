//
//  supplementButtonView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/27.
//

import SwiftUI

struct SupplementButtonView: View {
    @StateObject private var viewModel = SupplementButtonViewModel()
    @Environment(\.dismiss) var dismiss
    let date: Date
    let userId: String

    var body: some View {
        VStack {
            Button {
                viewModel.isShowPopover = true
            } label: {
                Image(systemName: "info.circle")
            }
            .font(.system(size: 20))
            .foregroundStyle(.black)
            .popover(isPresented: $viewModel.isShowPopover) {
                tapOver(date: date)
                    .presentationCompactAdaptation(PresentationAdaptation.popover)
            }
            .alert("確認", isPresented: $viewModel.isShowAlert) {
                Button("戻る", role: .cancel) {
                    viewModel.isShowAlert = false
                }
                
                Button("ブロック", role: .destructive) {
                    Task {
                        await viewModel.addBlockList(id: userId)
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("このユーザーをブロックしますか？")
            }

        }
    }
    
    private func tapOver(date: Date) -> some View {
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
                    .frame(width: 0.5)
                
                Button {
                    viewModel.isShowAlert = true
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
    SupplementButtonView(date: Date(), userId: "")
}
