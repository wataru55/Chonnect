//
//  OpenGraphDataCache.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/06.
//

import Foundation
import RealmSwift
import OpenGraph

//MARK: - OpenGraphDataCache
// OpenGraphDataモデルのキャッシュ用クラス
class OpenGraphDataCache: Object, ObjectKeyIdentifiable {
    // OpenGraphData.id (article.id) を主キーとする
    @Persisted(primaryKey: true) var id: String
    
    // ArticleCacheへの1対1の関連
    @Persisted var article: ArticleCache?
    
    // OpenGraphCacheの埋め込み
    @Persisted var openGraph: OpenGraphCache?
}

extension OpenGraphDataCache {
    convenience init(from model: OpenGraphData) {
        self.init()
        self.id = model.id
        self.article = ArticleCache(from: model.article)
        
        // .openGraph ではなく .openGraphSource を使う
        if let sourceDict = model.openGraphSource {
            self.openGraph = OpenGraphCache(from: sourceDict)
        }
    }
    
    func toModel() -> (article: Article, openGraphSource: [OpenGraphMetadata: String]?)? {
        // articleが必須なので、なければnilを返す
        guard let articleModel = article?.toModel() else { return nil }
        
        // openGraphはオプショナル
        // openGraph?.toModel() は [OpenGraphMetadata: String]? を返す
        let openGraphSource = openGraph?.toModel()
        
        // 復元した article と openGraphSource をタプルで返す
        return (article: articleModel, openGraphSource: openGraphSource)
    }
}

extension OpenGraphDataCache {
    convenience init(from ogpTuple: (article: Article, openGraphSource: [OpenGraphMetadata: String]?)) {
        self.init()
        self.id = ogpTuple.article.id
        self.article = ArticleCache(from: ogpTuple.article)
        
        if let sourceDict = ogpTuple.openGraphSource {
            // 上記で新しく定義したinitを利用
            self.openGraph = OpenGraphCache(from: sourceDict)
        }
    }
}

//MARK: - ArticleCache
// Articleモデルのキャッシュ用クラス
class ArticleCache: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var url: String
    @Persisted var createdAt: Date
}

extension ArticleCache {
    convenience init(from model: Article) {
        self.init()
        self.id = model.id
        self.url = model.url
        self.createdAt = model.createdAt
    }

    func toModel() -> Article {
        return Article(id: id, url: url, createdAt: createdAt)
    }
}

//MARK: - OpenGraphCache
class OpenGraphCache: EmbeddedObject {
    @Persisted var source: Map<String, String>
}

extension OpenGraphCache {
    convenience init(from sourceDict: [OpenGraphMetadata: String]) {
        self.init()
        sourceDict.forEach { (key, value) in
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
