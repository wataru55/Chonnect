//
//  UserHistoryRecord.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/06.
//

import Foundation

struct UserHistoryRecord: Hashable, Codable {
    let user: User
    var date: Date
}

extension UserHistoryRecord: UserIdentifiable {
    var userIdentifier: String { user.id }
}


