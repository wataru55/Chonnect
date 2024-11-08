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

    init(from object: EncountData) {
        self.userId = object.userId
        self.date = object.date
        self.rssi = object.rssi
    }

    // Realmオブジェクトに変換するメソッド
    func toRealmObject() -> EncountData {
        let realmObject = EncountData()
        realmObject.userId = self.userId
        realmObject.date = self.date
        realmObject.rssi = self.rssi
        return realmObject
    }
}
