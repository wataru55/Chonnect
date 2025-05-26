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
    @Published var state: ViewState = .idle
    
    @Published var errorMessage: String?
    
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
        self.state = .loading
        
        do {
            try await CurrentUserActions.report(to: id, content: reportText)
            self.state = .success
            self.reportText = ""
        } catch {
            self.errorMessage = "報告に失敗しました。もう一度お試しください。"
            self.state = .idle
        }
    }
}
