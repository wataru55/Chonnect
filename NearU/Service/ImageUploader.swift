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
    private static let storageFolder = "background_images"

    /// 画像を Firebase Storage にアップロードし、ダウンロードURLを Firestore に保存
    static func uploadImage(image: UIImage) async throws -> String {
        let documentId = try currentUserId()
        let imageData = try compress(image)
        let filename = "\(documentId)_backgroundImage.jpg"
        let ref = storageReference(for: filename)

        try await upload(data: imageData, to: ref)
        let urlString = try await downloadURL(from: ref)
        try await saveImageURL(urlString, for: documentId)

        return urlString
    }

    /// Firebase Storage に保存済みの画像のダウンロードURLを取得
    static func retrySaveProcess() async throws -> String {
        let documentId = try currentUserId()
        let filename = "\(documentId)_backgroundImage.jpg"
        let ref = storageReference(for: filename)
        
        // urlの取得とFirestore への保存
        let urlString = try await downloadURL(from: ref)
        try await saveImageURL(urlString, for: documentId)
        
        return urlString
    }

    // MARK: - Helper Methods

    /// 現在ログイン中ユーザーの Firestore document ID を取得
    private static func currentUserId() throws -> String {
        if let id = AuthService.shared.currentUser?.id {
            return id
        }
        throw FireStoreSaveError.missingUserId
    }

    /// UIImage を JPEG Data に圧縮
    private static func compress(_ image: UIImage) throws -> Data {
        if let data = image.jpegData(compressionQuality: 0.8) {
            return data
        }
        throw UploadImageError.imageConversionFailed
    }

    /// Firebase Storage の参照を生成
    private static func storageReference(for filename: String) -> StorageReference {
        return Storage.storage().reference(withPath: "\(storageFolder)/\(filename)")
    }

    /// Storage へデータをアップロード
    private static func upload(data: Data, to ref: StorageReference) async throws {
        let documentId = try currentUserId()
        let metadata = StorageMetadata()
        metadata.customMetadata = ["authorId": documentId]
        do {
            _ = try await ref.putDataAsync(data, metadata: metadata)
        } catch {
            throw UploadImageError.storageUploadFailed
        }
    }

    /// Storage からダウンロードURLを取得
    private static func downloadURL(from ref: StorageReference) async throws -> String {
        do {
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            throw UploadImageError.downloadURLFetchFailed
        }
    }

    /// Firestore に画像URLを保存
    private static func saveImageURL(_ url: String, for documentId: String) async throws {
        let docRef = Firestore.firestore().collection("users").document(documentId)
        do {
            try await docRef.updateData(["backgroundImageUrl": url])
        } catch {
            throw UploadImageError.firestoreSaveFailed
        }
    }
}

