//
//  SettingViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/27.
//

import SwiftUI
import Firebase
import FirebaseAuth

class SettingViewModel: ObservableObject {
    @Published var user: User
    @Published var inputEmail: String = ""
    @Published var inputPassword: String = ""
    @Published var isPrivate: Bool
    @Published var isShowAlert: Bool = false
    @Published var isShowCheck: Bool = false
    @Published var isShowResend: Bool = false
    @Published var isLoading: Bool = false
    @Published var message: String? = nil
    
    var currentEmail: String {
        Auth.auth().currentUser!.email ?? ""
    }
    
    var validateEmail: Bool {
        Validation.validateEmail(email: inputEmail)
    }
    
    var validatePassword: Bool {
        Validation.validatePassword(password: inputPassword, rePassword: inputPassword)
    }

    init(user: User) {
        self.user = user
        self.isPrivate = user.isPrivate
    }

    func updateIsPrivate() async throws {
        var data = [String: Bool]()

        data["isPrivate"] = self.isPrivate

        if !data.isEmpty {
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
    }
    
    func sendButtonPressed() {
        if validatePassword {
            Task {
                await reAuthAndSendEmailResetLink()
            }
        } else {
            self.isShowAlert = true
        }
    }
    
    @MainActor
    func reAuthAndSendEmailResetLink() async {
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        // 再認証
        guard await reAuthenticateOrFail() else { return }
        
        do {
            // メール送信
            try await AuthService.shared.sendResetEmailLink(email: inputEmail)
            self.isShowCheck = true
            
        } catch let error as AuthError {
            self.message = "送信に失敗しました。\n\(error.localizedDescription)"
            self.inputPassword = ""
        } catch {
            self.message = "予期せぬエラーです。もう一度お試しください。"
            self.inputPassword = ""
        }
    }
    
    @MainActor
    func reAuthAndSendPasswordResetMail() async {
        // 再認証
        guard await reAuthenticateOrFail() else { return }
        
        do {
            // メール送信
            try await AuthService.shared.sendResetPasswordMail(withEmail: currentEmail)
            self.message = "メールが送信されました"
            self.isShowResend = true
            
        } catch let error as AuthError {
            self.message = "送信に失敗しました。\n\(error.localizedDescription)"
            
        } catch {
            self.message = "予期せぬエラーです。もう一度お試しください。"
            self.inputPassword = ""
        }
    }
    
    @MainActor
    func checkComplete() async {
        self.isLoading = true
        
        let result = await AuthService.shared.reAuthenticate(email: inputEmail, password: inputPassword)
        if case .failure = result {
            self.message = "認証が完了していません。もう一度お試しください。"
            self.isLoading = false
            return
        }
        
        let sessionResult = await AuthService.shared.refreshUserSession()
        switch sessionResult {
        case .success:
            self.inputEmail = ""
            self.inputPassword = ""
            self.isLoading = false
            self.isShowCheck = false
            
        case .failure(let error):
            self.message = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteUser() async {
        guard !inputPassword.isEmpty else {
            self.message = "パスワードを入力してください"
            return
        }

        self.isLoading = true
        
        let result = await AuthService.shared.reAuthenticate(email: currentEmail, password: inputPassword)
        if case let .failure(error) = result {
            self.message = error.localizedDescription
        }
        
        do {
            try await CurrentUserService.deleteUser()
            
            self.isLoading = false
            
            AuthService.shared.signout()
            
        } catch {
            self.message = "予期せぬエラーです。もう一度お試しください。"
        }
    }
    
    @MainActor
    private func reAuthenticateOrFail() async -> Bool {
        let result = await AuthService.shared.reAuthenticate(email: currentEmail, password: inputPassword)
        if case let .failure(error) = result {
            if error == .invalidPassword {
                self.inputPassword = ""
            }
            self.message = error.localizedDescription
            return false
        }
        
        return true
    }
}
