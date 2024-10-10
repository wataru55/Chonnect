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
        }
    }

    @MainActor
    //新規ユーザを作成する関数
    func createUser(email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password) //FirebaseAuthenticationに新規ユーザを登録
            self.userSession = result.user //新規登録されたユーザーの情報をuserSessionに格納する．userはAuthDataResultのプロパティ．ユーザの情報を含む．
            await uploadUserData(uid: result.user.uid, username: username, email: email, isPrivate: false) //関数を非同期に実行

        } catch {
            print("DEBUG: Failed to register user with error \(error.localizedDescription)")
        }
    }

    @MainActor
    //ユーザデータを読み込む関数
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser //FirebaseAuthenticationから現在のユーザデータ情報を取得しuserSessionに格納
        guard let currentUid = userSession?.uid else { return } //currentUserのユーザidを取得し，currentUidに格納
        self.currentUser = try await UserService.fetchUser(withUid: currentUid)
        let snapshot = try await Firestore.firestore().collection("users").document(currentUid).getDocument()
        self.currentUser = try? snapshot.data(as: User?.self)
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
    private func uploadUserData(uid: String, username: String, email: String, isPrivate: Bool) async {
        let user = User(id: uid, username: username, email: email, isPrivate: isPrivate, connectList: [], snsLinks: [:]) //インスタンス化
        self.currentUser = user //curenntUserに現在のユーザ情報を格納
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return } //ユーザ情報をJSONデータにエンコードしてencodedUserに格納
        try? await Firestore.firestore().collection("users").document(user.id).setData(encodedUser) //encodedUser(JSONデータ？)をドキュメントに書き込む
    }

    //受信したユーザーIDをFirebase Firestoreデータベースに保存する
    func addUserIdToFirestore(_ receivedUserId: String) async throws {
        //Firestoreのドキュメントに追加
        if let userId = self.currentUser?.id {
            
            // TODO: ここのタイムスタンプはすれ違ったときの時間を引数で受け取って格納する
            let timestamp = Timestamp(date: Date())
            
            try await Firestore.firestore().collection("users")
                .document(userId)
                .collection("connectList")
                .document(receivedUserId)
                .setData([
                    "id": receivedUserId,
                    "timestamp": timestamp
                ])
        }
    }

    func removeUserIdFromFirestore(_ receivedUserId: String) async throws {
        // Firestoreのドキュメントから削除
        if let userId = self.currentUser?.id {
            try await Firestore.firestore().collection("users").document(userId).updateData([
                "connectList": FieldValue.arrayRemove([receivedUserId])
            ])
        }
    }
}
