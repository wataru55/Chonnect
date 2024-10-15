//
//  EncountData.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/10.
//

import Foundation
import RealmSwift

class EncountData: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var userId: String = ""
    @Persisted var date: Date = Date()
}

