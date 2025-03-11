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
    
    static func fetchFollowedUsers(receivedId: String) async throws -> [UserDatePair] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("follows").getDocuments()
        
        var followedUsers: [UserDatePair] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: NotificationData.self)
            let followedUser = try await fetchUser(withUid: data.userId)
            let userDatePair = UserDatePair(user: followedUser, date: data.date)
            followedUsers.append(userDatePair)
        }
        return followedUsers
    }
    
    static func fetchFollowers(receivedId: String) async throws -> [UserHistoryRecord] {
        guard let documentId = AuthService.shared.currentUser?.id else { return [] }
        let snapshot = try await Firestore.firestore().collection("users")
            .document(receivedId.isEmpty ? documentId : receivedId)
            .collection("followers").getDocuments()
        
        var followers: [UserHistoryRecord] = []
        
        for document in snapshot.documents {
            let data = try document.data(as: HistoryDataStruct.self)
            let follower = try await fetchUser(withUid: data.userId)
            let userHistoryRecord = UserHistoryRecord(user: follower, date: data.date, isRead: data.isRead)
            followers.append(userHistoryRecord)
        }
        return followers
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
        let data = ["article_url": url]
        do {
            try await Firestore.firestore().collection("users").document(userId).collection("article").addDocument(data: data)
        } catch {
            throw error
        }
    }
    
    // 記事をフェッチする関数
    static func fetchArticleLinks(withUid userId: String) async throws -> [String] {
        var articleUrls: [String] = []
        
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("article")
            .getDocuments()
        
        for document in snapshot.documents {
            if let articleUrlString = document.data()["article_url"] as? String {
                articleUrls.append(articleUrlString)
            }
        }
        
        return articleUrls
    }
    
    static func deleteArticleLink(url: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let query = Firestore.firestore().collection("users").document(documentId).collection("article").whereField("article_url", isEqualTo: url)
        
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
    
    static func followUser(receivedId: String, date: Date) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        let path = Firestore.firestore().collection("users")
        
        let followerData: [String: Any] = [
            "userId": documentId,
            "date": date,
            "isRead": false
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
    
    static func checkIsFollowed(receivedId: String) async -> Bool {
        guard let documentId = AuthService.shared.currentUser?.id else { return false }
        let path = Firestore.firestore().collection("users").document(documentId).collection("followers").document(receivedId)
        
        do {
            return try await path.getDocument().exists
        } catch {
            return false
        }
    }
    
    static func updateRead(userId: String) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(documentId).collection("followers").document(userId)
        
        do {
            try await ref.updateData(["isRead": true])
        } catch {
            throw error
        }
    }
    
    // FCMトークンをFirestoreに保存するメソッド
    static func setFCMToken(fcmToken: String) async {
        guard let documentId = AuthService.shared.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }
        
        let data: [String: Any] = ["fcmtoken": fcmToken]
        
        do {
            try await Firestore.firestore().collection("users").document(documentId).updateData(data)
            print("Document successfully updated with FCM token")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    static func updateUserProfile(username: String, bio: String, interestTags: [String]) async throws {
        guard let currentUser = AuthService.shared.currentUser else { return }
        
        var data = [String: Any]()
        
        if !username.isEmpty && currentUser.username != username {
            data["username"] = username
        }
        
        if !bio.isEmpty && currentUser.bio != bio {
            data["bio"] = bio
        }
        
        if currentUser.interestTags != interestTags {
            data["interestTags"] = interestTags
        }
        
        if !data.isEmpty {
            //Firestore Databaseのドキュメントを更新
            try await Firestore.firestore().collection("users").document(currentUser.id).updateData(data)
        }
    }
    
    static func deleteInterestTags(tag: [String]) async throws {
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        let ref = Firestore.firestore().collection("users").document(documentId)
        
        let data = ["interestTags": tag]
        
        try await ref.updateData(data)
    }
}

