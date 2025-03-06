//
//  ReportView.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/06.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var viewModel: SupplementButtonViewModel
    @FocusState var focus: Bool
    
    let userId: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("報告対象となる行為")
                    .font(.title3)
                    .padding(.leading)
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                        ・不適切なコンテンツ
                        ・なりすまし
                        ・その他の迷惑行為
                        """)
                    
                    Text("""
                        * 報告は匿名で行われ、相手に通知されることはありません。
                        * 虚偽の報告を繰り返すと、アカウントの制限対象となる場合があります。
                        """)
                }
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.horizontal)
                
                TextField("報告内容", text: $viewModel.reportText, axis: .vertical)
                    .font(.system(size: 15))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5...10)
                    .padding()
                    .focused(self.$focus)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HStack{
                                Spacer()
                                Button("閉じる"){
                                    self.focus = false
                                }
                            }
                        }
                    }
                
                if let message = viewModel.message {
                    Text(message)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .padding(.leading)
                        .onAppear {
                            Task {
                                try? await Task.sleep(nanoseconds: 3_000_000_000)
                                viewModel.message = nil
                            }
                        }
                }
                
                Button {
                    self.focus = false
                    Task {
                        await viewModel.addReport(id: userId)
                    }
                } label: {
                    Text("報告")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.mint)
                                .padding(.horizontal)
                        )
                }
            }
            .onDisappear {
                viewModel.reportText = ""
            }
        }
    }
}

//#Preview {
//    ReportView(viewModel: SupplementButtonViewModel())
//}
