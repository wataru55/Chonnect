//
//  Article.swift
//  NearU
//
//  Created by 高橋和 on 2025/06/03.
//

import Foundation

struct Article: Identifiable, Codable, Hashable {
    let id: String
    let url: String
    let createdAt: Date
    
}
