//
//  UserDatePair.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/21.
//

import Foundation

struct UserDatePair: Hashable, Codable {
    let user: User
    var date: Date
}

extension UserDatePair: UserIdentifiable {
    var userIdentifier: String { user.id }
}
