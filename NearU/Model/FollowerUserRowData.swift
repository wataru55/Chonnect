//
//  FollowerUserRowData.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/28.
//

import Foundation

struct FollowerUserRowData: Hashable {
    let record: UserHistoryRecord
    let tags: [InterestTag]
}
