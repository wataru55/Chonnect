//
//  InterestTagView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/25.
//

import SwiftUI

struct InterestTagView: View {
    @State private var isShowAlert: Bool = false
    let interestTag: [String]
    let isShowDeleteButton: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(interestTag, id: \.self) { tag in
                    HStack(spacing: 0) {
                        Image(systemName: "number")

                        Text(tag)
                            .fontWeight(.bold)
                    }
                    .font(.footnote)
                    .foregroundStyle(.indigo)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)
                    )
                    .overlay(alignment: .topTrailing) {
                        Button {
                            isShowAlert.toggle()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(.black)
                                .offset(x: 8, y: -5)
                        }
                        .alert("確認", isPresented: $isShowAlert) {
                            Button("削除", role: .destructive) {
                                Task {
                                    // TODO: 削除処理
                                }
                            }
                        } message: {
                            Text("このタグを削除しますか？")
                        }
                    }
                }
            }
        }
        .frame(height: 40)
        .padding(.leading, 15)
    }
}

#Preview {
    InterestTagView(interestTag: ["iOSDC2024", "Ruby会議", "doroidKaigi"], isShowDeleteButton: true)
}
