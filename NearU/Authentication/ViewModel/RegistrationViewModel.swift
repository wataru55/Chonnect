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
    @Published var rePassword = ""
    @Published var isShowCheck = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isEmailValid: Bool {
        Validation.validateEmail(email: email)
    }
    
    var isUsernameValid: Bool {
        Validation.validateUsername(username: username)
    }
    
    var isPasswordValid: Bool {
        Validation.validatePassword(password: password, rePassword: rePassword)
    }
    
    var isValidateUser: Bool {
        AuthService.shared.isValidUser()
    }
    
    var localUserName: String {
        UserDefaults.standard.string(forKey: "username") ?? ""
    }
    
    @MainActor
    func createUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password, username: username) //ユーザー作成
    }
    
    @MainActor
    func createUserToAuth() async throws{
        do {
            try await AuthService.shared.createUser(email: email, password: password, username: username)
        } catch {
            errorMessage = "入力されたメールアドレスはすでに登録されています"
            isLoading = false
            throw error
        }
    }
    
    @MainActor
    func sendValidationEmail() async throws {
        do {
            try await AuthService.shared.sendVerification()
        } catch let error as NSError {
            switch error.code {
            case 17010:
                errorMessage = "メール送信の回数制限を超えました。 \n少し待ってから再試行してください。"
            default:
                errorMessage = "通信エラーです。もう一度お試しください。"
            }
            isLoading = false
            throw error
        }
    }
    
    @MainActor
    func registerComplete() async throws {
        do {
            try await AuthService.shared.initAddToFireStore(username: localUserName)
        } catch {
            errorMessage = "通信エラーです。もう一度お試しください。"
            isLoading = false
            throw error
        }
    }
    
    @MainActor
    func deleteAuth() async throws {
        do {
            try await AuthService.shared.deleteUserAuth()
        } catch {
            errorMessage = "通信エラーです。もう一度お試しください。"
            isLoading = false
            throw error
        }
    
    }
    
    @MainActor
    func inputReset() {
        email = ""
        username = ""
        password = ""
        rePassword = ""
        isShowCheck = false
    }
    
}

