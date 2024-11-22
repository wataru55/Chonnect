//
//  HistroyDataStruct.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/03.
//

import SwiftUI

struct HistoryDataStruct: Codable {
    let userId: String
    var date: Date
    var isRead: Bool
    
    init(from object: HistoryData) {
        self.userId = object.userId
        self.date = object.date
        self.isRead = object.isRead
    }
    
    // Realmオブジェクトに変換するメソッド
    func toRealmObject() -> HistoryData {
        let realmObject = HistoryData()
        realmObject.userId = self.userId
        realmObject.date = self.date
        realmObject.isRead = self.isRead
        return realmObject
    }
}

