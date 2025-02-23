//
//  supplementButtonViewModel.swift
//  NearU
//
//  Created by 高橋和 on 2025/02/22.
//

import Foundation

class SupplementButtonViewModel: ObservableObject {
    @Published var isShowPopover = false
    
    func addBlockList(id: String) async {
        do {
            try await UserActions.blockUser(targetUserId: id)
        } catch {
            print("error: \(error)")
        }
    }
    
}
