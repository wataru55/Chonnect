//
//  EditAttributeTags.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/30.
//

import SwiftUI

struct EditAttributeTags: View {
    @EnvironmentObject var viewModel: CurrentUserProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    private let attributes: [String] = [
        "FullStack", "FrontEnd", "BackEnd", "Native", "Game", "SRE", "Security", "AI", "Hardware", "3DModeling"
    ]
        
    private let backgroundColor: Color = Color(red: 0.948, green: 0.949, blue: 0.97) //Listの背景色
    private let selectionLimit = 3
    
    var body: some View {
        VStack(spacing: 5) {
            Text("属性")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .padding(.top, 10)
            
            Text("あなたのエンジニアとしての属性を設定してください\n最大で\(selectionLimit)つまで選択できます")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                .padding(.vertical, 5)
            
            List {
                ForEach(attributes, id: \.self) { attribute in
                    Button {
                        if viewModel.attributes.contains(attribute) {
                            // 削除処理：配列から要素を削除する
                            if let index = viewModel.attributes.firstIndex(of: attribute) {
                                viewModel.attributes.remove(at: index)
                            }
                        } else {
                            // 追加処理：上限に達していなければ追加する
                            if viewModel.attributes.count < selectionLimit {
                                viewModel.attributes.append(attribute)
                            }
                        }
                    } label: {
                        HStack {
                            AttributeView(text: attribute)
                            
                            Spacer()
                            
                            if viewModel.attributes.contains(attribute) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold) // チェックマークを少し太くする
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(
            backgroundColor.ignoresSafeArea()
        )
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("属性")
        .navigationBack()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        try await viewModel.saveAttributes()
                        await MainActor.run {
                            dismiss()
                        }
                    }
                } label: {
                    Text("保存")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.isAttributesUnique ? Color.mint : Color.gray)
                }
                .disabled(!viewModel.isAttributesUnique)
                .alert("Error", isPresented: Binding<Bool> (
                    get: { viewModel.alertType != nil },
                    set: { if !$0 { viewModel.alertType = nil } }
                ), presenting: viewModel.alertType) { _ in
                    Button("OK", role: .cancel) { }
                } message: { alert in
                    Text(alert.message)
                }
            }
        }
        .onAppear() {
            viewModel.attributes = viewModel.user.attributes
        }
        .onDisappear() {
            viewModel.attributes = []
        }
    }
}

#Preview {
    EditAttributeTags()
}
