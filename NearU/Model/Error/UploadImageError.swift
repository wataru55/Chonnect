//
//  UploadImageError.swift
//  NearU
//
//  Created by 高橋和 on 2025/06/20.
//

import Foundation

enum UploadImageError: Error, LocalizedError {
    case imageConversionFailed
    case storageUploadFailed
    case downloadURLFetchFailed
    case firestoreSaveFailed

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "JPEGデータへの変換に失敗しました"
        case .storageUploadFailed:
            return "アップロードに失敗しました"
        case .downloadURLFetchFailed:
            return "URLの取得に失敗しました\n通信環境の良い場所で再施行してください"
        case .firestoreSaveFailed:
            return "URLの保存に失敗しました\n通信環境の良い場所で再施行してください"
        }
    }
}
