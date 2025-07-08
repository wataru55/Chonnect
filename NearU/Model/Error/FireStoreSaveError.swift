//
//  FireStoreSaveError.swift
//  NearU
//
//  Created by 高橋和 on 2025/05/19.
//

import Foundation

enum FireStoreSaveError: Error, LocalizedError {
    case missingUserId
    case encodingFailed
    case permissionDenied
    case networkError
    case serverError
    case unknown(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .missingUserId:
            return "ユーザーIDが見つかりません。再度ログインしてください。"
        case .encodingFailed:
            return "データのエンコードに失敗しました。"
        case .permissionDenied:
            return "データの保存が許可されていません。アクセス権限をご確認ください。"
        case .networkError:
            return "接続がタイムアウトしました。通信環境を確認してください。"
        case .serverError:
            return "サーバーに接続できません。時間をおいて再試行してください。"
        case .unknown(let error):
            return "不明なエラーが発生しました。\n\(error.localizedDescription)"
        }
    }
}
    
