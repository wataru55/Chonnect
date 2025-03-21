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
                
                VStack(alignment: .leading, spacing: 10) {
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
                .foregroundStyle(.gray)
                .padding(.horizontal)
                
                if !viewModel.isReportValid {
                    Text("200文字以内で入力してください")
                        .font(.footnote)
                        .foregroundColor(Color.orange)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                TextField("報告内容", text: $viewModel.reportText, axis: .vertical)
                    .font(.system(size: 15))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5...8)
                    .padding(.horizontal)
                    .padding(.top, 5)
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
                
                Button {
                    self.focus = false
                    Task {
                        await viewModel.addReport(id: userId)
                    }
                } label: {
                    Text(viewModel.isReportValid ? "報告" : "報告内容に不備があります")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.isReportValid ? Color.mint : Color.gray)
                                .padding(.horizontal)
                        )
                }
                .padding(.top, 10)
                .disabled(!viewModel.isReportValid)
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
