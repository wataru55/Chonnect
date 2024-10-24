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

    @MainActor
    // 新規ユーザを作成する関数
    func createUser(email: String, password: String, username: String) async throws {
        do {
            // Firebase Authenticationに新規ユーザを登録
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user // 新規登録されたユーザーの情報をuserSessionに格納

            // ユニークなuserIdが生成されるまで繰り返す
            var documentId = ""
            var isUnique = false

            repeat {
                documentId = generateRandomDocumentId() // ランダムなuserIdを生成
                isUnique = try await isDocumentIdUnique(documentId) // 一意性を確認
            } while !isUnique // 一意になるまで繰り返す

            // 一意なuserIdが確定したら、Firestoreにユーザーデータを保存
            await uploadUserData(id: documentId, uid: result.user.uid, username: username, email: email, isPrivate: false)

        } catch {
            print("DEBUG: Failed to register user with error \(error.localizedDescription)")
            throw error // エラーをスロー
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
    private func uploadUserData(id: String, uid: String, username: String, email: String, isPrivate: Bool) async {
        let user = User(id: id, uid: uid, username: username, email: email, isPrivate: isPrivate, connectList: [], snsLinks: [:]) // インスタンス化
        self.currentUser = user
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }

        // ドキュメントIDとしてuserIdを使用して保存
        try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
    }
}
