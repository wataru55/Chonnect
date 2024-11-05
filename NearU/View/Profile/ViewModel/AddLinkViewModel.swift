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
    @Published var urls: [String] = [""] // 複数のURLを保存する配列
    
    init(user: User) {
        self.user = user
    }

    @MainActor
    func updateSNSLink() async throws {
        // SNSリンクが入力されている場合の更新
        if !selectedSNS.isEmpty && !sns_url.isEmpty {
            let data = ["snsLinks.\(selectedSNS)": sns_url]

            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
            print("SNSリンクの更新完了")
        }
        
        // 複数のURLが入力されている場合の更新
        for url in urls {
            if !url.isEmpty {
                let data = ["abstract_url": url]
                try await Firestore.firestore()
                    .collection("users")
                    .document(user.id)
                    .collection("abstract")
                    .addDocument(data: data)
                print("URL \(url) が abstract コレクションに追加されました")
            }
        }
    }
}
