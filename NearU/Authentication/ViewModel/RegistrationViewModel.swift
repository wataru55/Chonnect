//
//  RegistrationViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    
    var isEmailValid: Bool {
        Validation.validateEmail(email: email)
    }
    
    var isUsernameValid: Bool {
        Validation.validateUsername(username: username)
    }

    @MainActor
    func createUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password, username: username) //ユーザー作成
        //初期化
        username = ""
        email = ""
        password = ""
    }
    
    @MainActor
    func checkEmail() -> Bool {
        if Validation.validateEmail(email: email) {
            return true // バリデーション成功時に遷移
        } else {
            errorMessage = "正しいメールアドレスを入力してください"
            return false
        }
    }
}

