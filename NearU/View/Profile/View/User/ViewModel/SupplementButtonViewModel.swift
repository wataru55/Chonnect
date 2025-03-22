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
    @Published var isShowReport = false
    @Published var reportText: String = ""
    
    @Published var message: String?
    
    var isReportValid: Bool {
        Validation.validateReport(report: reportText) && !reportText.isEmpty
    }
    
    func addBlockList(id: String) async {
        do {
            try await BlockUserManager.shared.blockUser(targetUserId: id)
        } catch {
            print("error: \(error)")
        }
    }
    
    @MainActor
    func addReport(id: String) async {
        guard !reportText.isEmpty else {
            self.message = "報告内容を記入してください"
            return
        }
        do {
            try await UserActions.report(to: id, content: reportText)
            self.reportText = ""
            self.message = "報告が完了しました"
        } catch {
            print("error: \(error)")
        }
    }
}
