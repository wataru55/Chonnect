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
    @Published var newEmail: String = ""
    @Published var password: String = ""
    @Published var isPrivate: Bool
    @Published var isShowAlert: Bool = false
    @Published var isShowCheck: Bool = false
    @Published var message: String? = nil
    
    var currentEmail: String {
        Auth.auth().currentUser!.email ?? ""
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
    
    @MainActor
    func reAuthAndEditEmail() async {
        do {
            // 再認証
            try await AuthService.shared.reAuthenticate(email: currentEmail, password: password)
            
            try await Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
            
            self.isShowCheck = true
            
        } catch {
            print("error: \(error)")
            self.message = "予期せぬエラーです。もう一度お試しください。"
            self.password = ""
        }
    }
    
    @MainActor
    func checkComplete() async {
        do {
            // 再認証
            try await AuthService.shared.reAuthenticate(email: newEmail, password: password)
            
            try await AuthService.shared.refreshUserSession()
            
            self.newEmail = ""
            self.password = ""
            self.isShowCheck = false
            
        } catch {
            print("error: \(error)")
            self.message = "予期せぬエラーです。もう一度お試しください。"
        }
    }
}
