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
    
    @MainActor
    func createUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password, username: username) //ユーザー作成
        //初期化
        username = ""
        email = ""
        password = ""
    }
    
    @MainActor
    func sendValidationEmail() async {
        defer {
            isLoading = false
        }
        
        isLoading = true
        
        do {
            try await AuthService.shared.createUser(email: email, password: password, username: username)
            isShowCheck = true
        } catch {
            print("error: \(error)")
            errorMessage = "入力されたメールアドレスはすでに登録されています"
        }
    }
    
    @MainActor
    func registerComplete() async {
        do {
            try await AuthService.shared.initAddToFireStore(username: username)
            isShowCheck = false
        } catch {
            print("error: \(error)")
            errorMessage = "予期せぬエラーです。もう一度お試しください。"
        }
    }
    
    @MainActor
    func resend() async {
        defer {
            isLoading = false
        }
        
        isLoading = true
        
        do {
            try await AuthService.shared.sendVerification()
        } catch {
            print("error: \(error)")
            errorMessage = "予期せぬエラーです。もう一度お試しください。"
        }
    }
    
    func deleteAuth() async {
        do {
            try await AuthService.shared.deleteUserAuth()
        } catch {
            print("error: \(error)")
            errorMessage = "予期せぬエラーです。もう一度お試しください。"
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

