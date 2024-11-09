//
//  UserRealtimeRecord.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/06.
//

import Foundation

struct UserRealtimeRecord: Hashable, Codable {
    let user: User
    var date: Date
    var rssi: Int
}
