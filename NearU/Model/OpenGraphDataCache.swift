//
//  OpenGraphDataCache.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/06.
//

import Foundation
import RealmSwift
import OpenGraph

class OpenGraphDataCache: EmbeddedObject {
    @Persisted var source: Map<String, String>
}

extension OpenGraphDataCache {
    convenience init(from model: OpenGraph) {
        self.init()
        model.source.forEach { (key, value) in
            self.source[key.rawValue] = value
        }
    }
    
    // 戻り値の型をOpenGraphから辞書に変更
    func toModel() -> [OpenGraphMetadata: String] {
        var sourceDict = [OpenGraphMetadata: String]()
        
        // 単一の 'element' を受け取るようにループを修正
        for element in self.source {
            // elementから .key と .value を取り出す
            let key = element.key
            let value = element.value
            
            if let metadataKey = OpenGraphMetadata(rawValue: key) {
                sourceDict[metadataKey] = value
            }
        }
        return sourceDict
    }
}
