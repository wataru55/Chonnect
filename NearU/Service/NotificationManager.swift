//
//  NotificationManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/29.
//

import Foundation

class NotificationManager {
    static let shared = NotificationManager()

    func sendPushNotification(fcmToken: String, username: String, documentId: String, date: Date) async {
        // エンドポイントが正しいか確認
        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/NearU/messages:send") else {
            print("Invalid URL")
            return
        }

        // 通知メッセージの作成
        let dateString = "\(date.timeIntervalSince1970)"
        let notification = FCMMessage.Notification(title: "フォロー通知", body: "\(username)さんにフォローされました")
        let data = FCMMessage.Data(documentId: documentId, date: dateString)
        let message = FCMMessage.Message(token: fcmToken, notification: notification, data: data)
        let fcmMessage = FCMMessage(message: message)

        guard let jsonData = try? JSONEncoder().encode(fcmMessage) else {
            print("Failed to create JSON data")
            return
        }

        // アクセストークンの取得
        var accessToken = ""
        Task {
            do {
                accessToken = try await generateAccessToken()
            } catch {
                print("Failed to generate access token: \(error)")
                return
            }
        }
        // TODO: トークンを取得

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        // 指定されたURLにリクエストを送信
        // データタスクの生成
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response: \(httpResponse.statusCode)")
            }
        }.resume() // resume()でデータタスクを実行
    }

    func generateAccessToken() async throws -> String {
        return "dummy"
    }
}
