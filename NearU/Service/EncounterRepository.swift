//
//  EncounterRepository.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/13.
//

import Foundation
@preconcurrency import RealmSwift

// UserProfileのキャッシュデータ操作を専門に担当するアクター
actor EncounterRepository{
    var realm: Realm!
    
    init() async throws {
        realm = try await Realm(actor: self)
    }
    
    func saveOrUpdate(encountData: HistoryDataStruct) async {
        do {
            try await realm.asyncWrite {
                // UserProfileDataCacheオブジェクトを準備
                let encountCache = UserEncounterCache()
                encountCache.userId = encountData.userId
                encountCache.lastEncounterDate = encountData.date
                            
                // .modifiedを指定することで、主キー(id)が同じデータがあれば更新、なければ新規追加する
                realm.add(encountCache, update: .modified)
            }
        } catch {
            print("Error saving or updating UserProfileDataCache: \(error)")
        }
    }
    
    func fetch(userId: String) -> Date? {
        guard let encounterCache = realm.object(ofType: UserEncounterCache.self, forPrimaryKey: userId) else {
            return nil // キャッシュが存在しない
        }
        
        return encounterCache.lastEncounterDate
    }

}


