//
//  NotificationManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/10/29.
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore
import JWTKit

class NotificationManager {
    static let shared = NotificationManager()

    func sendPushNotification(fcmToken: String, username: String, documentId: String, date: Date) async {
        // エンドポイントが正しいか確認
        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/nearu-46768/messages:send") else {
            print("Invalid URL")
            return
        }

        // 通知データの作成
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
        do {
            accessToken = try await generateAccessToken()
        } catch {
            print("Failed to generate access token: \(error)")
            return
        }

        // FCMに対する通知リクエストの設定
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        // 指定されたURLにリクエストを送信
        // 非同期メソッドを使用してリクエストを送信
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Response: \(httpResponse.statusCode)")
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseBody)")
                }
            }
        } catch {
            print("Error sending push notification: \(error.localizedDescription)")
        }
    }

    func generateAccessToken() async throws -> String {
        // Private.jsonを読み込む
        guard let credentials = loadServiceAccountCredentials() else {
            throw NSError(domain: "AccessTokenError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load service account credentials"])
        }
        // JWTの署名として利用
        let privateKey = credentials.privateKey
        let clientEmail = credentials.clientEmail

        // JWTサイン用の署名者を初期化
        let signer = JWTSigner.rs256(key: try .private(pem: privateKey))

        // JWTのペイロードを作成
        let payload = PayloadData(
            iss: clientEmail,
            scope: "https://www.googleapis.com/auth/firebase.messaging",
            aud: "https://oauth2.googleapis.com/token",
            exp: Date().addingTimeInterval(3600), // 1時間後に期限切れ
            iat: Date()
        )

        // JWTトークンの生成
        let jwt = try signer.sign(payload)

        // JWTをアクセストークンに変換
        // リクエストの設定
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // リクエストボディの設定
        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
        request.httpBody = body.data(using: .utf8)

        // 非同期リクエストの送信とレスポンスの処理
        let (data, response) = try await URLSession.shared.data(for: request)

        // レスポンスの確認
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw NSError(domain: "AccessTokenError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get access token: \(responseBody)"])
        }

        // アクセストークンの解析
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let token = json["access_token"] as? String {
            return token
        } else {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw NSError(domain: "AccessTokenError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid access token response: \(responseBody)"])
        }
    }

    func loadServiceAccountCredentials() -> (privateKey: String, clientEmail: String)? {
        // アプリバンドル内のJSONファイルのURLを取得
        guard let url = Bundle.main.url(forResource: "Private", withExtension: "json") else {
            print("Failed to locate Private.json in app bundle")
            return nil
        }

        // ファイルからデータを読み込む
        guard let data = try? Data(contentsOf: url) else {
            print("Failed to read data from service-account.json")
            return nil
        }
        // JSONデータを解析
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let privateKey = json["private_key"] as? String,
               let clientEmail = json["client_email"] as? String {
                return (privateKey, clientEmail)
            } else {
                print("Invalid JSON structure in service-account.json")
                return nil
            }
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
}

struct PayloadData: JWTPayload {
    let iss: String
    let scope: String
    let aud: String
    let exp: Date
    let iat: Date

    func verify(using signer: JWTSigner) throws {
        // 必要に応じて検証ロジックを実装
    }
}
