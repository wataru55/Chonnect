//
//  SettingView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/27.
//

import SwiftUI

enum SettingViewDestination: Hashable {
    case blockList
    case editEmail
    case editPassword
    case deleteAccount
}
    

struct SettingView: View {
    @StateObject var viewModel : SettingViewModel
    @State private var isShowAlert: Bool = false

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: SettingViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("SNSリンクへのアクセスを相互フォローに限定")) {
                        Toggle(isOn: $viewModel.isPrivate) {
                            Text("SNSのアクセス制限")
                        }
                        .tint(.mint)
                        .onChange(of: viewModel.isPrivate) {
                            Task { try await viewModel.updateIsPrivate() }
                        }
                    }
                    
                    Section(header: Text("ブロックしたユーザーの確認および解除")) {
                        NavigationLink(value: SettingViewDestination.blockList) {
                            Text("ブロック一覧")
                        }
                    }
                    
                    Section(header: Text("ログイン情報の変更")) {
                        NavigationLink(value: SettingViewDestination.editEmail) {
                            Text("メールアドレス変更")
                        }
                        
                        NavigationLink(value: SettingViewDestination.editPassword) {
                            Text("パスワード変更")
                        }
                    }
                    
                    AppInfo()
                    
                    Section(header: Text("ログアウト・退会")) {
                        Button {
                            isShowAlert = true
                        } label: {
                            Text("ログアウト")
                                .foregroundStyle(.pink)
                        }
                        
                        NavigationLink(value: SettingViewDestination.deleteAccount) {
                            Text("退会")
                        }
                    }
                }
                .navigationTitle("設定")
                .toolbarBackground(Color.mint, for: .navigationBar)
            }
            .navigationDestination(for: SettingViewDestination.self) { destination in
                switch destination {
                case .blockList:
                    BlockListView()
                    
                case .editEmail:
                    EditEmailView(viewModel: viewModel)
                
                case .editPassword:
                    EditPasswordView(viewModel: viewModel)
                    
                case .deleteAccount:
                    DeleteView(viewModel: viewModel)
                }
            }
            .alert("確認", isPresented: $isShowAlert) {
                Button("キャンセル", role: .cancel) {
                    isShowAlert = false
                }
                Button("ログアウト", role: .destructive) {
                    isShowAlert = false
                    AuthService.shared.signout()
                }
            } message: {
                Text(
                    "ログアウトしますか？"
                )
            }
            
        }//navigaiton
    }//body
    
    private func AppInfo() -> some View {
        Section(header: Text("このアプリについて")) {
            HStack {
                Text("Product").foregroundStyle(Color.gray)
                Spacer()
                Text("Chonnect")
            }
            HStack {
                Text("Compatibility").foregroundStyle(Color.gray)
                Spacer()
                Text("iPhone")
            }
            HStack {
                Text("Developer").foregroundStyle(Color.gray)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Wataru Takahashi")
                    Text("Tsubasa Watanabe")
                    Text("Ukyo Taniguchi")
                }
            }
            HStack {
                Text("Version").foregroundStyle(Color.gray)
                Spacer()
                Text("1.0.0")
            }
        }
    }
}//view

#Preview {
    SettingView(user: User.MOCK_USERS[0])
}
