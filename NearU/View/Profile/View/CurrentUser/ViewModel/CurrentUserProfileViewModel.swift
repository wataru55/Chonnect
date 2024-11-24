//
//  EditProfileViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import PhotosUI
import SwiftUI
import Firebase
import Combine

class CurrentUserProfileViewModel: ObservableObject {
    @Published var user: User

    @Published var selectedBackgroundImage: PhotosPickerItem? {
        didSet { Task { await loadBackgroundImage(fromItem: selectedBackgroundImage) }}
    }

    @Published var backgroundImage: Image?

    @Published var username = ""
    @Published var fullname = ""
    @Published var bio = ""

    private var uiBackgroundImage: UIImage?
    private var cancellables = Set<AnyCancellable>()

    init() {
        if let currentUser = AuthService.shared.currentUser {
            self.user = currentUser
        } else {
            self.user = User(id: "", uid: "", username: "", email: "", isPrivate: false, connectList: [], snsLinks: [:])
        }
        setupSubscribers()
    }

    func setupSubscribers() {
        // currentUserプロパティが変更されるとクロージャが実行される
        AuthService.shared.$currentUser
            .compactMap({ $0 })
            .sink { [weak self] currentUser in
                self?.user = currentUser
                self?.username = currentUser.username
                self?.fullname = currentUser.fullname ?? ""
                self?.bio = currentUser.bio ?? ""
            }
            .store(in: &cancellables)
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
    //Firebase Databaseのユーザ情報を変更する関数
    func updateUserData() async throws {
        //update profile image if changed
        var data = [String: Any]() //keyがString型，valueがAnyの辞書を定義

        if let uiImage = uiBackgroundImage {
            let imageUrl = try await ImageUploader.uploadImage(image: uiImage) //String型の画像のダウンロードURLが返される．
            data["backgroundImageUrl"] = imageUrl //辞書に格納
        }

        if !username.isEmpty && user.username != username {

            data["username"] = username
        }

        //update name if changed
        if !fullname.isEmpty && user.fullname != fullname {
            data["fullname"] = fullname
        }

        //update bio if changed
        if !bio.isEmpty && user.bio != bio {
            data["bio"] = bio
        }

        if !data.isEmpty {
            //Firestore Databaseのドキュメントを更新
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
            print("complete")
        }
    }
}
