//
//  User.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Hashable, Codable {
    var id: String
    let uid: String
    var username: String
    var backgroundImageUrl: String?
    var bio: String?
    var email: String
    var isPrivate: Bool
    var snsLinks: [String: String]
    var fcmtoken: String?

    var isCurrentUser: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false } //現在のユーザ情報があればそれをcurrentUidに格納
        return currentUid == uid
    }
}

extension User {
    static var MOCK_USERS: [User] = [
        .init(id: "FEstc1eg",uid: NSUUID().uuidString, username: "ironman", bio: "I am ironman", email: "ironman@gmail.com", isPrivate: false, snsLinks: [:]),

            .init(id: "FEstc1eg", uid: NSUUID().uuidString, username: "spiderman",
              bio: "With great power comes great responsibility", email: "spiderman@gmail.com", isPrivate: true, snsLinks: [:])
    ]
}
