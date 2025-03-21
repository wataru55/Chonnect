//
//  Validation.swift
//  NearU
//
//  Created by 高橋和 on 2025/03/17.
//

import Foundation

struct Validation {
    static func validateEmail(email: String) -> Bool {
        guard !email.isEmpty else { return false }
        
        // 正規表現
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
            return false
        }
        
        return true
    }
    
    static func validateUsername(username: String) -> Bool {
        guard !username.isEmpty else { return false }
        
        guard username.count <= 20 else { return false }
        
        return true
    }
    
    static func validatePassword(password: String, rePassword: String) -> Bool {
        guard password == rePassword else { return false }
        
        guard password.rangeOfCharacter(from: .whitespaces) == nil else {
            return false
        }
        
        guard password.count >= 6 && password.count <= 20 else {
            return false
        }
        
        return true
    }
    
    static func validateBio(bio: String) -> Bool {
        // 空白・改行・タブなどを正規表現で取り除く
        let trimmed = bio.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        
        // 残った文字の長さが100以下かどうかをチェック
        return trimmed.count <= 100
    }
    
    static func validateInterestTag(tags: [String]) -> Bool {
        for tag in tags {
            guard tag.count <= 20 else { return false }
        }
        
        return true
    }
}
