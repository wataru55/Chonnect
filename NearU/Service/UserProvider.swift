//
//  UserProvider.swift
//  NearU
//
//  Created by 高橋和 on 2025/08/21.
//

import Foundation

class UserProvider {
    // 内部にUserRepositoryを持つ
    private let userRepo: UserRepository

    init() async throws {
        // 初期化時にUserRepositoryを準備
        self.userRepo = try await UserRepository()
    }

    /// 複数のユーザーIDを受け取り、キャッシュとネットワークを使ってユーザー情報を返す
    func fetchUsers(with ids: [String]) async throws -> [User] {
        // IDリストが空なら、何もしない
        guard !ids.isEmpty else { return [] }
        
        // 1. まずキャッシュに一括で問い合わせる
        let cachedUsers = await userRepo.fetch(userIds: ids)
        let cachedUserIds = Set(cachedUsers.map { $0.id })
        
        var finalUsers = cachedUsers
        
        // 2. キャッシュに不足しているユーザーIDを特定
        let missingUserIds = ids.filter { !cachedUserIds.contains($0) }
        
        // 3. 不足分があれば、ネットワークに一括で問い合わせる
        if !missingUserIds.isEmpty {
            print("UserProvider: \(missingUserIds.count)件の不足情報をネットワークから取得します...")
            let newFetchedUsers = try await UserService.fetchUsers(missingUserIds)
            
            // 4. 新しく取得したユーザーをキャッシュに保存
            await userRepo.saveOrUpdate(users: newFetchedUsers)
            
            // 5. 結果を合体
            finalUsers.append(contentsOf: newFetchedUsers)
        } else {
            print("UserProvider: 全てのユーザー情報は新鮮なキャッシュ内にありました。")
        }
        
        return finalUsers
    }
}
