//
//  AbstractLinksViewModel.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/16.
//

import Foundation
import Firebase

class AbstractLinkModel: ObservableObject {
    @Published var abstractLinks: [String: String] = [:]
    private let userId: String

    init(userId: String) {
        self.userId = userId
        Task {
            await fetchAbstractLinks()
        }
    }

    @MainActor
    func fetchAbstractLinks() async {
        do {
            let links = try await UserService.fetchAbstractLinks(withUid: userId)
            self.abstractLinks = [:]
        } catch {
            print("Error fetching abstract links: \(error.localizedDescription)")
        }
    }
}
