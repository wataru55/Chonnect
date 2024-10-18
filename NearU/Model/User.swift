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
    var profileImageUrl: String?
    var backgroundImageUrl: String?
    var fullname: String?
    var bio: String?
    var email: String
    var isPrivate: Bool
    var connectList: [String]
    var snsLinks: [String: String]

    var isCurrentUser: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false } //現在のユーザ情報があればそれをcurrentUidに格納
        return currentUid == uid
    }
}

extension User {
    static var MOCK_USERS: [User] = [
        .init(id: "FEstc1eg",uid: NSUUID().uuidString, username: "ironman", profileImageUrl: "ironman1", fullname: "Tony Stark", bio: "I am ironman", email: "ironman@gmail.com", isPrivate: false, connectList: [], snsLinks: [:]),

            .init(id: "FEstc1eg", uid: NSUUID().uuidString, username: "spiderman", profileImageUrl: "spiderman1", fullname: "peter parker",
              bio: "With great power comes great responsibility", email: "spiderman@gmail.com", isPrivate: true, connectList: [], snsLinks: [:])
    ]
}
