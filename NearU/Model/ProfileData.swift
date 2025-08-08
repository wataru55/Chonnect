//
//  ProfileData.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/09.
//

import Foundation
import OpenGraph

struct ProfileData {
    let user: User
    let follows: [User]
    let followers: [User]
    let skillTags: [WordElement]
    let ogp: [(article: Article, openGraphSource: [OpenGraphMetadata: String]?)]
}
    
