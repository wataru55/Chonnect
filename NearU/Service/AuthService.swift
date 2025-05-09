//
//  Auth.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase

enum AuthError: Error, LocalizedError {
    case invalidEmail
    case invalidPassword
    case emailAlreadyInUse
    case invalidSession
    case userDataNotFound
    case emailNotVerified
    case tooManyRequests
    case networkError
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "メールアドレスが間違っています。"
        case .invalidPassword:
            return "パスワードが間違っています。"
        case .emailAlreadyInUse:
            return "そのメールアドレスは既に登録されています。\nアプリを利用される方はログインしてください。"
        case .invalidSession:
            return "セッションが無効です。再度ログインしてください。"
        case .userDataNotFound:
            return "ユーザーデータが見つかりませんでした。"
        case .emailNotVerified:
            return "メールアドレスの認証が完了していません。"
        case .tooManyRequests:
            return "メール送信の回数制限を超えました。\n少し待ってから再試行してください。"
        case .networkError:
            return "ネットワークに接続できません。通信環境を確認してください。"
        case .serverError:
            return "サーバーで問題が発生しました。\n時間をおいて再試行してください。"
        default:
            return "予期せぬエラーが発生しました。"
        }
    }
}

class AuthService {
    @Published var userSession: FirebaseAuth.User? //Firebaseのユーザ認証に用いられる変数
    @Published var currentUser: User?
    
    static let shared = AuthService() //シングルトンインスタンス
    
    init() {
        Task{
            self.userSession = Auth.auth().currentUser
            try await initializeCurrentUser()
        }
    }
    
    @MainActor
    func initializeCurrentUser() async throws {
        let result = await CurrentUserService.loadCurrentUser()
        switch result {
        case .success(let user):
            self.currentUser = user
        case .failure(let error):
            throw error
        }
    }
    
    func isValidUser() async -> Bool {
        guard let currentUser = Auth.auth().currentUser else { return false }
        
        do {
            try await currentUser.reload()
            return currentUser.isEmailVerified
        } catch {
            return false
        }
    }
    
    @MainActor
    func login(email: String, password: String) async -> Result<Bool, AuthError> {
        do {
            // サインイン
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            
            // ユーザーデータ読み込み
            let userResult = await CurrentUserService.loadCurrentUser()
            switch userResult {
            case .success(let user):
                self.currentUser = user
            case .failure(let error):
                return .failure(error)
            }
            
            return .success(true)
            
        } catch let error as NSError {
            print("DEBUG: ログイン失敗 - domain: \(error.domain), code: \(error.code), message: \(error.localizedDescription)")

            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return .failure(.invalidEmail)
                
            case AuthErrorCode.wrongPassword.rawValue:
                return .failure(.invalidPassword)
                
            case AuthErrorCode.userNotFound.rawValue:
                return .failure(.userDataNotFound)

            case AuthErrorCode.networkError.rawValue:
                return .failure(.networkError)

            case AuthErrorCode.internalError.rawValue,
                 AuthErrorCode.tooManyRequests.rawValue:
                return .failure(.serverError)

            default:
                return .failure(.unknown)
            }
        }
    }
    
    func refreshUserSession() async throws {
        try await Auth.auth().currentUser?.reload()
    }
    
    private func checkEmailVerification(for user: FirebaseAuth.User) async -> Result<Bool, AuthError> {
        do {
            try await user.reload()
            return user.isEmailVerified ? .success(true) : .failure(.emailNotVerified)
            
        } catch {
            return .failure(.serverError)
        }
    }
    
    func reAuthenticate(email: String, password: String) async -> Result<Bool, AuthError> {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await Auth.auth().currentUser?.reauthenticate(with: credential)
            return .success(true)
        } catch let error as NSError {
            print("DEBUG: 再認証失敗 - domain: \(error.domain), code: \(error.code), message: \(error.localizedDescription)")
            switch error.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return .failure(.invalidEmail)
                
            case AuthErrorCode.wrongPassword.rawValue, AuthErrorCode.invalidCredential.rawValue:
                return .failure(.invalidPassword)
                
            case AuthErrorCode.networkError.rawValue:
                return .failure(.networkError)
                
            default:
                return .failure(.serverError)
            }
        }
    }
    
    //パスワードリセットメールを送信
    func sendResetPasswordMail(withEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.networkError.rawValue:
                throw AuthError.networkError
                
            case AuthErrorCode.tooManyRequests.rawValue:
                throw AuthError.tooManyRequests
            
            default:
                throw AuthError.serverError
            }
        }
    }
    
    func sendVerification() async -> Result<Bool, AuthError> {
        guard let currentUser = Auth.auth().currentUser else {
            return .failure(.invalidSession)
        }
        
        do {
            try await currentUser.sendEmailVerification()
            return .success(true)
            
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.tooManyRequests.rawValue:
                return .failure(.tooManyRequests)
                
            case AuthErrorCode.networkError.rawValue:
                return .failure(.networkError)
                
            default:
                return .failure(.serverError)
            }
        }
    }
    
    // 新規ユーザを作成する関数
    func createUser(email: String, password: String, username: String) async -> Result<Bool, AuthError> {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            return .success(true)
        } catch let error as NSError {
            print("DEBUG: ログイン失敗: \(error.code) \(error.localizedDescription)")
            
            // Authenticationのエラー処理
            if error.domain == AuthErrorDomain {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    return .failure(.emailAlreadyInUse)
                    
                case AuthErrorCode.networkError.rawValue:
                    return .failure(.networkError)
                    
                case AuthErrorCode.internalError.rawValue, AuthErrorCode.tooManyRequests.rawValue:
                    return .failure(.serverError)
                    
                default:
                    return .failure(.unknown)
                }
            }
            
            return .failure(.unknown)
        }
    }
    
    func deleteUserAuth() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        try await currentUser.delete()
    }
    
    func initAddToFireStore(username: String) async -> Result<Bool, AuthError> {
        guard let currentUser = Auth.auth().currentUser else {
            return .failure(.invalidSession)
        }
    
        do {
            // 一意なuserIdを確定
            let documentId = try await IDGenerator.generateUniqueUserId()
            
            // Firestoreにユーザーデータを保存
            let result = await createUserDocument(id: documentId, uid: currentUser.uid, username: username, isPrivate: true)
            switch result {
            case .success:
                self.userSession = currentUser
                return .success(true)
            case .failure(let error):
                return .failure(error)
            }
            
        } catch let error as AuthError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }
    
    func signout() {
        try? Auth.auth().signOut() //try?はエラーを無視
        self.userSession = nil
        self.currentUser = nil
        
        //BLE通信の停止
        BLECentralManager.shared.stopCentralManagerDelegate()
        BLEPeripheralManager.shared.stopPeripheralManagerDelegate()
    }
    
    //Firestore Databaseにユーザ情報を追加する関数
    private func createUserDocument(id: String, uid: String, username: String, isPrivate: Bool) async -> Result<Bool, AuthError> {
        let user = User(id: id, uid: uid, username: username, isPrivate: isPrivate, snsLinks: [:], interestTags: [])
        self.currentUser = user

        do {
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            return .success(true)
        } catch let error as NSError {
            print("DEBUG: ユーザーデータの保存に失敗しました: \(error.code) \(error.localizedDescription)")
            
            switch error.code {
            case FirestoreErrorCode.unavailable.rawValue,
                 FirestoreErrorCode.deadlineExceeded.rawValue:
                return .failure(.networkError)
            default:
                return .failure(.serverError)
            }
        }
    }
}
