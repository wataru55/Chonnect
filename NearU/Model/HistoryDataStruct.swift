//
//  HistroyDataStruct.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/03.
//

import SwiftUI

struct HistoryDataStruct: Codable, UserIdentifiable {
    let userId: String
    var date: Date
    
    var userIdentifier: String { userId }
    
    init(from object: HistoryData) {
        self.userId = object.userId
        self.date = object.date
    }
    
    // Realmオブジェクトに変換するメソッド
    func toRealmObject() -> HistoryData {
        let realmObject = HistoryData()
        realmObject.userId = self.userId
        realmObject.date = self.date
        return realmObject
    }
}

