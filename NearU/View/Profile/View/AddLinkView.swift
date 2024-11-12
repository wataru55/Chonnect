//
//  AddLinkView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/05.
//

import SwiftUI

struct AddLinkView: View {
    @EnvironmentObject var viewModel: AddLinkViewModel
    @State private var snsUrls: [String] = [""]
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea() // 指定された背景色を適用

                VStack(alignment: .leading, spacing: 0) {
                    Text("SNSのURLを追加")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .padding(.leading, 5)
                        .padding(.vertical, 10)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 3) {
                            ForEach(snsUrls.indices, id: \.self) { index in
                                TextField("URLを入力", text: $snsUrls[index])
                                    .textInputAutocapitalization(.never) // 自動で大文字にしない
                                    .disableAutocorrection(true) // スペルチェックを無効にする
                                    .font(.subheadline)
                                    .padding(12)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button {
                                snsUrls.append("")
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .offset(y: 3)
                                    Text("入力欄を追加")
                                        .padding(.top, 5)
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .foregroundStyle(Color.mint)
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 10)

                            Text("SNS一覧")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 5)
                                .padding(.vertical, 10)

                            ScrollView(.horizontal, showsIndicators: false) {
                               HStack {
                                   if viewModel.snsUrls.isEmpty {
                                       Text("SNSのリンクがありません")
                                           .font(.subheadline)
                                           .fontWeight(.bold)
                                           .foregroundColor(.gray)
                                           .padding()
                                   } else {
                                       ForEach(Array(viewModel.snsUrls.keys), id: \.self) { key in
                                           if let url = viewModel.snsUrls[key] {
                                               SNSLinkButtonView(selectedSNS: key, sns_url: url, isShowDeleteButton: true)
                                                   .environmentObject(viewModel)
                                           }
                                       }
                                   }
                               } // HStack
                            } // ScrollView
                            .padding(.leading)
                            .padding(.bottom, 10)

                        } //vstack
                    } //scrollview
                }// vstack
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("SNSの追加・削除")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chevron.backward")
                            .onTapGesture {
                                dismiss()
                            }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                try await viewModel.updateSNSLink(urls: snsUrls)
                                await viewModel.loadSNSLinks()
                                await MainActor.run {
                                    snsUrls = [""]
                                }
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "plus.app")
                                Text("追加")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(Color.mint)
                        }
                    }
                }
            }//zstack
        }//navigationstack
    }
}

#Preview {
    AddLinkView()
        .environmentObject(AddLinkViewModel())
}
