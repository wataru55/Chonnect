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
    @Published var isValidateUser: Bool = false
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
    
    var localUserName: String {
        UserDefaults.standard.string(forKey: "username") ?? ""
    }
    
    var isRegisterProcessing: Bool {
        UserDefaults.standard.bool(forKey: "registration")
    }
    
    @MainActor
    func registerUserAndSendEmail() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await createUserToAuth()
        
        switch result {
        case .success:
            break
            
        case .failure(let error):
            errorMessage = error.localizedDescription
            return
        }
        
        let mailResult = await AuthService.shared.sendVerification()
        switch mailResult {
        case .success:
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        
        isShowCheck = true
    }
    
    @MainActor
    private func createUserToAuth() async -> Result<Bool, AuthError> {
        let result = await AuthService.shared.createUser(email: email, password: password, username: username)
        
        if case .success = result {
            UserDefaults.standard.setValue(username, forKey: "username")
            UserDefaults.standard.setValue(true, forKey: "registration")
        }
        
        return result
    }
    
    @MainActor
    func registerComplete() async {
        let result = await AuthService.shared.initAddToFireStore(username: localUserName)
        switch result {
        case .success:
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    @MainActor
    func reSendEmailVerification() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await AuthService.shared.sendVerification()
        switch result {
        case .success:
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func loadUserData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AuthService.shared.initializeCurrentUser()
        } catch {
            errorMessage = (error as? AuthError)?.localizedDescription ?? "予期せぬエラーです。"
        }
    }
    
    @MainActor
    func checkUserValidation() async {
        isLoading = true
        let isValid = await AuthService.shared.isValidUser()
        self.isValidateUser = isValid
        isLoading = false
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

