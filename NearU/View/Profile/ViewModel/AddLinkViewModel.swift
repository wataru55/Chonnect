//
//  AddLinkViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/13.
//

import PhotosUI
import SwiftUI
import Firebase

class AddLinkViewModel: ObservableObject {
    @Published var user: User
    @Published var selectedSNS: String = ""
    @Published var sns_url: String = ""

    init(user: User) {
        self.user = user
    }

    @MainActor
    func updateSNSLink() async throws {
        if !selectedSNS.isEmpty && !sns_url.isEmpty {
            let data = ["snsLinks.\(selectedSNS)": sns_url]

            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
            print("complete")
        }
    }
}
