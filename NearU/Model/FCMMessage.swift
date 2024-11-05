//
//  FCMMessage.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/30.
//

import Foundation

struct FCMMessage: Codable {
    struct Message: Codable {
        let token: String
        let notification: Notification
        let data: Data
    }

    struct Notification: Codable {
        let title: String
        let body: String
    }

    struct Data: Codable {
        let documentId: String
        let date: String
    }

    let message: Message
}
