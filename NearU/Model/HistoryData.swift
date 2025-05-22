//
//  HistoryData.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/03.
//

import Foundation
import RealmSwift

class HistoryData: Object, Identifiable {
    @Persisted(primaryKey: true) var userId: String = ""
    @Persisted var date: Date = Date()
}
