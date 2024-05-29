//
//  SettingViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/27.
//

import SwiftUI
import Firebase

class SettingViewModel: ObservableObject {
    @Published var user: User

    @Published var isPrivate: Bool

    init(user: User) {
        self.user = user
        self.isPrivate = user.isPrivate
    }

    func updateIsPrivate() async throws {
        var data = [String: Bool]()

        data["isPrivate"] = self.isPrivate

        if !data.isEmpty {
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
    }
}
