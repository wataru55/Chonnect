//
//  ViewTransitionManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/02.
//

import SwiftUI
import Combine

class ViewTransitionManager: ObservableObject {
    static let shared = ViewTransitionManager()

    @Published var showProfile: Bool = false
    @Published var selectedUser: User? = nil
    private var cancellable: AnyCancellable?

    private init() {
        // NotificationCenterから通知を受信
        cancellable = NotificationCenter.default.publisher(for: Notification.Name("didReceiveRemoteNotification"))
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let userInfo = notification.userInfo, let userId = userInfo["userId"] as? String {
                    // userIdを使用してUserデータを取得
                    Task {
                        await self.loadUser(userId: userId)
                    }
                }
            }
    }

    func loadUser(userId: String) async {
        do {
            let user = try await UserService.fetchUser(withUid: userId)
            DispatchQueue.main.async {
                self.selectedUser = user
                self.showProfile = true
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
}
