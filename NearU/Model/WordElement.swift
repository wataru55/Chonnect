//
//  WordElement.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/19.
//

import SwiftUI

struct WordElement: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var skill: String
}
