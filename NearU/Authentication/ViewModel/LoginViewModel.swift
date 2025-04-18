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
        let result = await AuthService.shared.login(email: email, password: password) //login関数を実行
        switch result {
        case .success:
            inputReset()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func inputReset() {
        email = ""
        password = ""
    }
}
