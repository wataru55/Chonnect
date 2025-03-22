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
        
        return trimmed.count <= 100
    }
    
    static func validateReport(report: String) -> Bool {
        let trimmed = report.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        return trimmed.count <= 200
    }
    
    static func validateInterestTag(tags: [String]) -> Bool {
        for tag in tags {
            guard tag.count <= 20 else { return false }
        }
        
        return true
    }
    
    static func validateSNSURL(urls: [String]) -> Bool {
        let serviceHostMapping: [String] = [
            "github.com",
            "twitter.com", "x.com",
            "instagram.com",
            "youtube.com", "youtu.be",
            "facebook.com",
            "tiktok.com",
            "qiita.com",
            "zenn.dev",
            "wantedly.com",
            "linkedin.com",
            "threads.net"
        ]

        let filteredUrls = urls
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for url in filteredUrls {
            guard let urlObject = URL(string: url),
                  let host = urlObject.host,
                  let scheme = urlObject.scheme,
                  scheme == "http" || scheme == "https" else {
                return false
            }
            
            // ホスト名を厳密に比較（例: www.github.com のようなケースも考慮したければ .hasSuffix にしてもOK）
            let isValidHost = serviceHostMapping.contains(where: { host == $0 || host.hasSuffix("." + $0) })
            if !isValidHost {
                return false
            }
        }
        
        return true
    }
    
    static func validateArticleUrls(urls: [String]) -> Bool {
        let filteredUrls = urls
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for url in filteredUrls {
            guard let urlObject = URL(string: url),
                  let scheme = urlObject.scheme,
                  scheme == "http" || scheme == "https" else {
                return false
            }
        }

        return true
    }


}
