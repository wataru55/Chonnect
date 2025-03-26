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

class AuthService {
    @Published var userSession: FirebaseAuth.User? //Firebaseのユーザ認証に用いられる変数
    @Published var currentUser: User?

    static let shared = AuthService() //シングルトンインスタンス
    
    let subCollections = ["follows", "followers", "history",
                          "notifications", "article", "selectedTags",
                          "interestTags", "blocks", "blockedBy"]

    init() {
        Task{ try await loadUserData() }
    }

    @MainActor //メインスレットで行われることを保証
    func login(withEmail email: String, password: String) async throws { //throwsはエラーを投げる可能性がある時につける
        do { //エラーを補足するためにdo-catch構文
            let result = try await Auth.auth().signIn(withEmail: email, password: password) //Firebaseを利用してログイン．成功→ resultにユーザ情報が格納　失敗→エラー
            self.userSession = result.user
            try await loadUserData() //関数を非同期に実行

        } catch { //doブロックでエラーが発生したら実行される
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
            throw error  // エラーを再スロー
        }
    }
    
    func refreshUserSession() async throws {
        try await Auth.auth().currentUser?.reload()
    }
    
    func reAuthenticate(email: String, password: String) async throws {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        try await Auth.auth().currentUser?.reauthenticate(with: credential)
    }
    
    func resetPassword(withEmail email: String) async throws { //パスワードリセット
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: パスワードリセットに失敗しました。エラー: \(error.localizedDescription)")
            throw error
        }
    }
    
    func sendVerification() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        try await currentUser.sendEmailVerification()
    }

    @MainActor
    // 新規ユーザを作成する関数
    func createUser(email: String, password: String, username: String) async throws {
        do {
            // Firebase Authenticationに新規ユーザを登録
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // 確認用メールを送信
            try await result.user.sendEmailVerification()

        } catch {
            print("DEBUG: Failed to register user with error \(error.localizedDescription)")
            throw error // エラーをスロー
        }
    }
    
    func deleteUserAuth() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        try await currentUser.delete()
    }
    
    func initAddToFireStore(username: String) async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        try await currentUser.reload()
        
        if currentUser.isEmailVerified {
            // ユニークなuserIdが生成されるまで繰り返す
            var documentId = ""
            var isUnique = false

            repeat {
                documentId = generateRandomDocumentId() // ランダムなuserIdを生成
                isUnique = try await isDocumentIdUnique(documentId) // 一意性を確認
            } while !isUnique // 一意になるまで繰り返す
            
            // 一意なuserIdが確定したら、Firestoreにユーザーデータを保存
            await uploadUserData(id: documentId, uid: currentUser.uid, username: username, isPrivate: true)
            
            await MainActor.run {
                self.userSession = currentUser
            }
        }
    }

    // 8文字のランダムなdocumentIdを生成する関数
    private func generateRandomDocumentId(length: Int = 8) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }

    func isDocumentIdUnique(_ userId: String) async throws -> Bool {
        let query = Firestore.firestore().collection("users").whereField("userId", isEqualTo: userId).limit(to: 1)
        let snapshot = try await query.getDocuments()
        return snapshot.isEmpty
    }

    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser // Firebase Authenticationから現在のユーザデータ情報を取得
        guard let currentUid = userSession?.uid else { return } // currentUserのuidを取得
        // uidフィールドがcurrentUidと一致するユーザードキュメントをクエリ
        let querySnapshot = try await Firestore.firestore().collection("users").whereField("uid", isEqualTo: currentUid).getDocuments()

        if let document = querySnapshot.documents.first {
            // Firestoreから取得したデータをデコード
            var user = try document.data(as: User.self)
            // ドキュメントIDを手動でセット
            user.id = document.documentID
            self.currentUser = user
        } else {
            print("DEBUG: ユーザーデータが見つかりませんでした。")
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
    private func uploadUserData(id: String, uid: String, username: String, isPrivate: Bool) async {
        let user = User(id: id, uid: uid, username: username, isPrivate: isPrivate, snsLinks: [:], interestTags: [])
        self.currentUser = user
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }

        // ドキュメントIDとしてuserIdを使用して保存
        try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
    }
    
    func deleteUser() async throws {
        guard let currentUser = self.currentUser else { return }
        
        await deleteSubCollection(documentId: currentUser.id)
        
        try await Firestore.firestore().collection("users").document(currentUser.id).delete()
        
        try await Auth.auth().currentUser?.delete()
    }
    
    private func deleteSubCollection(documentId: String) async {
        let ref = Firestore.firestore().collection("users").document(documentId)
        
        do {
            for collection in subCollections {
                let subCollectionRef = ref.collection(collection)
                let documents = try await subCollectionRef.getDocuments()
                
                let batch = Firestore.firestore().batch()
                for document in documents.documents {
                    batch.deleteDocument(document.reference)
                }
                try await batch.commit()
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
