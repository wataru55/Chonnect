//
//  LoginViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?

    @MainActor
    func signIn() async throws {
        do {
            try await AuthService.shared.login(withEmail: email, password: password) //login関数を実行
            inputReset()
        } catch {
            errorMessage = "ログインに失敗しました。もう一度お試しください。"
            
        }
    }
    
    @MainActor
    func inputReset() {
        email = ""
        password = ""
    }
}
