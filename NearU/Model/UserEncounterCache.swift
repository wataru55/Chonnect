//
//  UserEncounterCache.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/13.
//

import Foundation
import RealmSwift

class UserEncounterCache: Object, ObjectKeyIdentifiable {
    // すれちがった相手のユーザーID。UserCacheへの「外部キー」の役割
    @Persisted(primaryKey: true) var userId: String
    
    // 最後にすれちがった日時
    @Persisted var lastEncounterDate: Date
}
