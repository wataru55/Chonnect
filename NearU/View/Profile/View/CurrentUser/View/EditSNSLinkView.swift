//
//  AddLinkView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/05.
//

import SwiftUI

struct EditSNSLinkView: View {
    @EnvironmentObject var viewModel: EditSNSLinkViewModel
    @Environment(\.dismiss) var dismiss
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色
    
    // 登録可能なSNS一覧
    let availableSNS = [
        "GitHub", "X", "Instagram", "YouTube", "Facebook",
        "TikTok", "Qiita", "Zenn", "Wantedly", "LinkedIn", "Threads"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SNSのURLを追加")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(.leading, 5)
                            .padding(.top, 10)
                        
                        VStack(alignment: .leading) {
                            Text("登録可能なSNS:")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Text(availableSNS.joined(separator: ", "))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 3)
                        .padding(.leading, 9)
                        .padding(.bottom, 10)
                        
                        if !viewModel.isSNSLinkValid {
                            Text("登録できないURLが含まれています")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 5)
                        }
                        
                        VStack(spacing: 3) {
                            ForEach(viewModel.inputUrls.indices, id: \.self) { index in
                                TextField("URLを入力", text: $viewModel.inputUrls[index])
                                    .modifier(URLFieldModifier())
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button {
                                viewModel.inputUrls.append("")
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
                            
                            if viewModel.snsUrls.isEmpty {
                                Text("SNSのリンクがありません")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 10) {
                                    ForEach(Array(viewModel.snsUrls.keys), id: \.self) { key in
                                        if let url = viewModel.snsUrls[key] {
                                            SNSLinkButtonView(selectedSNS: key, sns_url: url, isShowDeleteButton: true)
                                                .environmentObject(viewModel)
                                        }
                                    }
                                } // LazyVGrid
                                .padding(.horizontal, 10)
                            }
                        } // VStack
                    } // VStack
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("SNSの追加・削除")
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.black)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                try await viewModel.updateSNSLink(urls: viewModel.inputUrls)
                                await viewModel.loadSNSLinks()
                                await MainActor.run {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("保存")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(viewModel.isSNSLinkValid && !viewModel.isInputUrlsAllEmpty ? Color.mint : Color.gray)
                        }
                        .disabled(!viewModel.isSNSLinkValid || viewModel.isInputUrlsAllEmpty)
                    }
                }
            } // ZStack
            .modifier(EdgeSwipe())
        } // NavigationStack
        .onDisappear {
            viewModel.inputUrls = [""]
        }
    }
}

#Preview {
    EditSNSLinkView()
        .environmentObject(EditSNSLinkViewModel())
}
