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
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("SNSのURLを追加")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.leading, 5)
                    .padding(.vertical, 10)

                ScrollView {
                    VStack(spacing: 3) {
                        ForEach(snsUrls.indices, id: \.self) { index in
                            TextField("URLを入力", text: $snsUrls[index])
                                .textInputAutocapitalization(.never) // 自動で大文字にしない
                                .disableAutocorrection(true) // スペルチェックを無効にする
                                .font(.subheadline)
                                .padding(12)
                                .padding(.horizontal, 10)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        Button(action: {
                            snsUrls.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .offset(y: 3)
                                Text("入力欄を追加")
                                    .padding(.top, 5)
                                    .font(.system(size: 15, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                    }
                }
            }// vstack
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("SNSの追加・削除")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .onTapGesture {
                            isPresented = false
                        }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try await viewModel.updateSNSLink(urls: snsUrls)
                            await viewModel.loadSNSLinks()
                            await MainActor.run {
                                isPresented = false
                            }
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.down")
                            Text("追加")
                                .fontWeight(.bold)
                                .offset(y: 3)
                        }
                    }
                }
            }
        }//navigationstack
    }
}

#Preview {
    AddLinkView(isPresented: .constant(true))
}
