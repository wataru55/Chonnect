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
    var interest: String
}

extension Array where Element == WordElement {
    static func generate(forSwiftUI: Bool = false) -> [WordElement] {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        var words = [WordElement]()
        for _ in 0...15 {
            words.append(
                WordElement(id: UUID(),
                            name: String((0...Int.random(in: 4...9)).map{ _ in letters.randomElement()! }),
                            skill: String(Int.random(in: 1...10)),
                            interest: String(Int.random(in: 1...10)))
            )
        }
        return words
    }
}
