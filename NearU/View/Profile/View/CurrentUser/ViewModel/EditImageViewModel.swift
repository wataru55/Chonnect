//
//  EditImageViewModel.swift
//  NearU
//
//  Created by 高橋和 on 2025/06/28.
//

import PhotosUI
import SwiftUI
import Firebase
import Combine

enum AlertType {
    case okOnly(message: String)
    case retryURLFetch(message: String)
    case retrySaveToFireStore(message: String)

    var message: String {
        switch self {
        case .okOnly(let msg), .retryURLFetch(let msg), .retrySaveToFireStore(let msg):
            return msg
        }
    }
}

class EditImageViewModel: ObservableObject {
    @Published var user: User
    
    @Published var backgroundImage: Image?
    @Published var state: ViewState = .idle
    @Published var alertType: AlertType? = nil
    
    @Published var selectedBackgroundImage: PhotosPickerItem? {
        didSet {
            if selectedBackgroundImage == nil {
                backgroundImage = nil // nilの場合、backgroundImageもクリア
                uiBackgroundImage = nil
            } else {
                Task { await loadBackgroundImage(fromItem: selectedBackgroundImage) }
            }
        }
    }
    
    private var uiBackgroundImage: UIImage?
    
    init() {
        if let currentUser = AuthService.shared.currentUser {
            self.user = currentUser
        } else {
            self.user = User(id: "", uid: "", username: "", isPrivate: false, snsLinks: [:], interestTags: [])
        }
    }
    
    @MainActor
    func loadBackgroundImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return } //オプショナルでないか確認
        //データを読み込みバイナリデータとして取得
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        //バイナリデータをUIImage型に変換
        guard let uiImage = UIImage(data: data) else { return } //バイナリデータが有効な画像データであるか検証するため
        self.uiBackgroundImage = uiImage
        //UIImage(画像の操作に使われる型)をImage型（SwiftUI の画像表示用オブジェクト）に変換．
        self.backgroundImage = Image(uiImage: uiImage)
    }
    
    @MainActor
    func updateProfileImage() async {
        guard let uiImage = uiBackgroundImage else {
            self.state = .idle
            self.alertType = .okOnly(message: "画像が選択されていません")
            return
        }
        
        self.state = .loading
        
        do {
            let urlString = try await ImageUploader.uploadImage(image: uiImage)

            self.user.backgroundImageUrl = urlString
            AuthService.shared.currentUser?.backgroundImageUrl = urlString
            self.state = .success
            
        } catch let error as UploadImageError{
            self.state = .idle
            
            switch error {
            case .imageConversionFailed, .storageUploadFailed:
                self.alertType = .okOnly(message: error.localizedDescription)
                
            case .downloadURLFetchFailed:
                self.alertType = .retryURLFetch(message: error.localizedDescription)
                
            case .firestoreSaveFailed:
                self.alertType = .retrySaveToFireStore(message: error.localizedDescription)
            }
            
        } catch {
            self.state = .idle
            self.alertType = .okOnly(message: error.localizedDescription)
        }
    }
    
    @MainActor
    func retrySaveProcess() async {
        self.state = .loading
        do {
            let urlString = try await ImageUploader.retrySaveProcess()
            self.user.backgroundImageUrl = urlString
            AuthService.shared.currentUser?.backgroundImageUrl = urlString
            self.state = .success
            
        } catch let error as UploadImageError{
            self.state = .idle
            
            switch error {
            case .imageConversionFailed, .storageUploadFailed:
                self.alertType = .okOnly(message: error.localizedDescription)
                
            case .downloadURLFetchFailed:
                self.alertType = .retryURLFetch(message: error.localizedDescription)
                
            case .firestoreSaveFailed:
                self.alertType = .retrySaveToFireStore(message: error.localizedDescription)
            }
            
        } catch {
            self.state = .idle
            self.alertType = .okOnly(message: error.localizedDescription)
        }
    }
    
    @MainActor
    func resetSelectedImage() {
        selectedBackgroundImage = nil
        backgroundImage = nil
    }
}
