//
//  BlockListViewModel.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/27.
//

import Foundation

final class BlockListViewModel: ObservableObject {
    @Published var blockList: [User] = []
    
    @MainActor
    func loadBlockList() async {
        let blockUserIds = BlockUserManager.shared.blockUserIds
        
        do {
            blockList = try await UserService.fetchUsers(blockUserIds)
        } catch {
            print("error: \(error)")
        }
    }
    
    func unblockUser(user: User) async {
        do {
            try await BlockUserManager.shared.unblockUser(id: user.id)
            await MainActor.run {
                blockList.removeAll { $0 == user }
            }
        } catch {
            print("error: \(error)")
        }
    }
}
