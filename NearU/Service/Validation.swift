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
}
