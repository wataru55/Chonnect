//
//  OpenGraphData.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/08.
//

import Foundation
import OpenGraph

struct OpenGraphData: Identifiable {
    var id: String { article.id }
    let article: Article
    let openGraph: OpenGraph?
}
