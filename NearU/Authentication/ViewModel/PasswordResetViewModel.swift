//
//  PasswordResetViewModel.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/25.
//

import Foundation

class PasswordResetViewModel: ObservableObject {
    @Published var email: String = ""
    
    func resetPassword() async throws {
        guard !email.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "メールアドレスを入力してください。"])
        }
        try await AuthService.shared.sendResetPasswordMail(withEmail: email)
    }
}
