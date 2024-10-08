//
//  ImageUploader.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/25.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ImageUploader {
    static func uploadImage(image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil } //UIImageをjpeg形式のバイナリデータに変換
        let filename = NSUUID().uuidString //filenameにUUIDのString型データを格納
        //Firebase Storageの特定のパスに画像ファイルを保存する参照を作成
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")

        // Firebase Storageに保存する際のメタデータを設定
        let metadata = StorageMetadata()

        // 認証されたユーザーのUIDを取得して, authorIdとしてメタデータに追加
        if let uid = AuthService.shared.currentUser?.id {
            metadata.customMetadata = ["authorId": uid]  // ここでUIDを設定
        } else {
            print("DEBUG: Failed to get current user's UID.")
            return nil
        }

        do {
            //Firebase StorageのputDataAsyncメソッドでバイナリデータを参照先へupload (返り値を期待しないためlet _)
            let _ = try await ref.putDataAsync(imageData, metadata: metadata)
            //Firebase Storageに保存されたファイルのダウンロードURLを取得
            let url = try await ref.downloadURL()
            return url.absoluteString //取得したダウンロードURLを文字列として返す
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            return nil
        }
    }
}

