//
//  EncountDataStruct.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/12.
//

import SwiftUI

struct EncountDataStruct: Hashable, Codable {
    let userId: String
    var date: Date
    var rssi: Int
}
