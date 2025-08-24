//
//  WordElementCache.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/06.
//

import Foundation
import RealmSwift

class WordElementCache: Object, ObjectKeyIdentifiable {
    // WordElement.id -> UUIDを主キーとして設定
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var skill: String
    
    // WordElementからWordElementCacheを簡単に作成するためのイニシャライザ
    convenience init(from element: WordElement) {
        self.init()
        self.id = element.id
        self.name = element.name
        self.skill = element.skill
    }
}

extension WordElementCache {
    func toModel() -> WordElement {
        return WordElement(id: self.id, name: self.name, skill: self.skill)
    }
}
