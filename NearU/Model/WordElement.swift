//
//  WordElement.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/19.
//

import SwiftUI

struct WordElement: Codable, Hashable {
    let name: String
    let skill: Int
    let interest: Int
}

extension Array where Element == WordElement {
    static func generate(forSwiftUI: Bool = false) -> [WordElement] {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        var words = [WordElement]()
        for _ in 0...15 {
            words.append(
                WordElement(name: String((0...Int.random(in: 4...9)).map{ _ in letters.randomElement()! }),
                            skill: Int.random(in: 1...10),
                            interest: Int.random(in: 1...10))
            )
        }
        return words
    }
}
