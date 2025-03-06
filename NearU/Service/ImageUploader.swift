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
    static func uploadImage(image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return } //UIImageをjpeg形式のバイナリデータに変換
        guard let documentId = AuthService.shared.currentUser?.id else { return }
        
        //let filename = "\(documentId)_\(UUID().uuidString).jpg"
        let filename = "\(documentId)_backgroundImage.jpg"
        //Firebase Storageの特定のパスに画像ファイルを保存する参照を作成
        let ref = Storage.storage().reference(withPath: "/background_images/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.customMetadata = ["authorId": documentId]

        do {
            //Firebase Storageへの保存
            let _ = try await ref.putDataAsync(imageData, metadata: metadata)
            //Firebase Storageに保存されたファイルのダウンロードURLを取得
            let url = try await ref.downloadURL()
            let urlString = url.absoluteString
            //FireStoreのuserドキュメントに保存
            try await saveImageURLToFirestore(userId: documentId, imageURL: urlString)
            
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            return
        }
    }
    
    static func saveImageURLToFirestore(userId: String, imageURL: String) async throws {
        let docRef = Firestore.firestore().collection("users").document(userId)

        try await docRef.updateData(["backgroundImageUrl": imageURL])
        
    }
}

