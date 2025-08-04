//
//  User.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Hashable, Codable, UserIdentifiable {
    var id: String
    let uid: String
    var username: String
    var backgroundImageUrl: String?
    var bio: String?
    var isPrivate: Bool
    var snsLinks: [String: String]
    var attributes: [String]
    var interestTags: [String]
    var fcmtoken: String?

    var isCurrentUser: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false } //現在のユーザ情報があればそれをcurrentUidに格納
        return currentUid == uid
    }
    
    var userIdentifier: String { id }
}

extension User {
    static var MOCK_USERS: [User] = [
        .init(id: "FEstc1eg",uid: NSUUID().uuidString, username: "ironman", bio: "I am ironman",
              isPrivate: false, snsLinks: [:], attributes: [], interestTags: []),

            .init(id: "FEstc1eg", uid: NSUUID().uuidString, username: "spiderman",
                  bio: "With great power comes great responsibility",
                  isPrivate: true, snsLinks: [:], attributes: [], interestTags: [])
    ]
}
