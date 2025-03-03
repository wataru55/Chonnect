//
//  supplementButtonViewModel.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.
//

import Foundation

class SupplementButtonViewModel: ObservableObject {
    @Published var isShowPopover = false
    @Published var isShowAlert = false
    
    func addBlockList(id: String) async {
        do {
            try await BlockUserManager.shared.blockUser(targetUserId: id)
        } catch {
            print("error: \(error)")
        }
    }
    
}
