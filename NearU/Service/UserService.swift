//
//  UserService.swift
//  InstagramTutorial
//
//  Created by  髙橋和 on 2024/05/07.
//

import Foundation
import Firebase

struct UserService {
    static func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument() //ユーザidを使用してFirestoreDatabaseからドキュメントを取得
        return try snapshot.data(as: User.self) //snapshotからUser型にデータをデコードして値を返す
    }

    static func fetchUsers(_ userIds: [String]) async throws -> [User] {
        var users = [User]()

        for userId in userIds {
            let docRef = Firestore.firestore().collection("users").document(userId)
            let document = try await docRef.getDocument()

            if let user = try? document.data(as: User.self) {
                users.append(user)
            }
        }
        return users
    }

    static func fetchfollowedUsers() async throws -> [UserDatePair] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users").document(documentId).collection("follows").getDocuments()

        var followedUsers: [UserDatePair] = []

        for document in snapshot.documents {
            let data = try document.data(as: EncountDataStruct.self)
            let followedUser = try await fetchUser(withUid: data.userId)
            let userDatePair = UserDatePair(user: followedUser, date: data.date)
            followedUsers.append(userDatePair)
        }
        return followedUsers
    }

    static func saveSNSLink(serviceName: String, url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }

        let data = ["snsLinks.\(serviceName)": url]
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(data)
        } catch {
            throw error
        }
    }

    static func deleteSNSLink(serviceName: String, url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }

        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(["snsLinks.\(serviceName)": FieldValue.delete()])
        } catch {
            throw error
        }
    }

    static func seveArticleLink(userId: String, url: String) async throws {
        let data = ["abstract_url": url]
        do {
            try await Firestore.firestore().collection("users").document(userId).collection("abstract").addDocument(data: data)
        } catch {
            throw error
        }
    }

    // 記事をフェッチする関数
    static func fetchAbstractLinks(withUid userId: String) async throws -> [String] {
        var abstractUrls: [String] = []

        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("abstract")
            .getDocuments()

        for document in snapshot.documents {
            if let abstractUrlString = document.data()["abstract_url"] as? String {
                abstractUrls.append(abstractUrlString)
            }
        }

        return abstractUrls
    }

    static func deleteArticleLink(url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let query = Firestore.firestore().collection("users").document(documentId).collection("abstract").whereField("abstract_url", isEqualTo: url)

        // Firestoreから削除
        do {
            let snapshot = try await query.getDocuments()

            if let document = snapshot.documents.first {
                try await document.reference.delete()
            }
        } catch {
            throw error
        }
    }

    // ユーザーの選択されたタグをFirestoreに保存する関数(言語)
    static func saveLanguageTags(userId: String, selectedTags: [String]) async throws {
        let ref = Firestore.firestore().collection("users").document(userId).collection("selectedTags").document("languageTags")
        try await ref.setData(["tags": selectedTags])
    }

    // ユーザーの選択されたタグをFirestoreに保存する関数(ライブラリ、フレームワーク)
    static func saveFrameworkTags(userId: String, selectedTags: [String]) async throws {
        let ref = Firestore.firestore().collection("users").document(userId).collection("selectedTags").document("frameworkTags")
        try await ref.setData(["tags": selectedTags])
    }

    // 選択したタグをフェッチする関数(言語)
    static func fetchLanguageTags(withUid id: String) async throws -> Tags {
        let snapshot = try await Firestore.firestore().collection("users").document(id).collection("selectedTags").document("languageTags").getDocument()
        return try snapshot.data(as: Tags.self)
    }

    // 選択したタグをフェッチする関数(ライブラリ、フレームワーク)
    static func fetchFrameworkTags(withUid id: String) async throws -> Tags {
        let snapshot = try await Firestore.firestore().collection("users").document(id).collection("selectedTags").document("frameworkTags").getDocument()
        return try snapshot.data(as: Tags.self)
    }

    static func followUser(receivedId: String, date: Date) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }

        let path = Firestore.firestore().collection("users")

        let followerData: [String: Any] = [
            "userId": documentId,
            "date": date
        ]

        let followData: [String: Any] = [
            "userId": receivedId,
            "date": date
        ]

        do {
            // 相手のfollowersコレクションに保存
            try await path.document(receivedId).collection("followers").document(documentId).setData(followerData)
            // 相手のnotificationsコレクションに保存
            try await path.document(receivedId).collection("notifications").document(documentId).setData(followerData)
            // 自分のfollowsコレクションに保存
            try await path.document(documentId).collection("follows").document(receivedId).setData(followData)
            print("Followed successfully saved")
        } catch {
            print("Error saving Followed: \(error)")
            throw error
        }
    }

    static func deleteFollowedUser(receivedId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }

        do {
            // 相手のfollowersコレクションから削除
            try await Firestore.firestore().collection("users").document(receivedId).collection("followers").document(documentId).delete()
            // 自分のfollowsコレクションから削除
            try await Firestore.firestore().collection("users").document(documentId).collection("follows").document(receivedId).delete()
            print("Followed successfully deleted")
        } catch {
            print("Error deleting Followed: \(error)")
            throw error
        }
    }

    func fetchNotifications() async {
        guard let myDocumentId = AuthService.shared.currentUser?.id else { return }

        let startTime = Date()
        let notificationsRef = Firestore.firestore().collection("users").document(myDocumentId).collection("notifications")

        do {
            let snapshot = try await notificationsRef.getDocuments()

            for document in snapshot.documents {
                if let data = try? document.data(as: NotificationData.self) {
                    // Realmに保存
                    await RealmManager.shared.storeData(data.userId, date: data.date)
                }
                // 通知を削除
                do {
                    try await document.reference.delete()
                    print("Notification deleted successfully.")
                } catch {
                    print("Error deleting notification: \(error)")
                }
            }
        } catch {
            print("Error fetching notifications: \(error)")
        }
        // 経過時間の計算
        let elapsed = Date().timeIntervalSince(startTime)
        let minimumLoadingTime: TimeInterval = 2.0 // 2秒

        if elapsed < minimumLoadingTime {
            let remainingTime = minimumLoadingTime - elapsed
            // Task.sleepで待機
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }
    }

}
