//
//  FollowFollowerData.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/23.
//

import Foundation

struct FollowFollowerData: Hashable {
    let follows: [User]
    let followers: [User]
    let userName: String
    let tabNum: Int
}
    
