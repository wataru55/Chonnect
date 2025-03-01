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
    @Published var message: String? = nil
    
    var currentEmail: String {
        Auth.auth().currentUser!.email ?? ""
    }

    init(user: User) {
        self.user = user
        self.isPrivate = user.isPrivate
        //self.currentEmail = self.currentEmail = Auth.auth().currentUser!.email ?? ""
    }

    func updateIsPrivate() async throws {
        var data = [String: Bool]()

        data["isPrivate"] = self.isPrivate

        if !data.isEmpty {
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
    }
    
    @MainActor
    func editEmail() async {
        do {
            try await Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
            self.newEmail = ""
            self.message = "確認メールが送信されました"
        } catch let error as NSError {
            // FirebaseAuthErrorの場合
            if let code = AuthErrorCode.Code(rawValue: error.code) {
                switch code {
                case .requiresRecentLogin:
                    // 再認証が必要
                    self.isShowAlert = true
                default:
                    // その他のエラー
                    print("error: \(error.localizedDescription)")
                }
            } else {
                // AuthErrorCodeに該当しないエラーの場合
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func reAuthAndEditEmail() async {
        do {
            // 再認証
            try await AuthService.shared.reAuthenticate(password: password)
            
            try await Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
            
            self.password = ""
            self.newEmail = ""
            self.message = "確認メールが送信されました"
            
        } catch {
            print("error: \(error)")
            self.message = "再認証に失敗しました"
            self.password = ""
        }
    }
}
