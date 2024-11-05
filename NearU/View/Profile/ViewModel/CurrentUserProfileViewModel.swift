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

    @Published var selectedLanguageTags: [String] = []
    @Published var selectedFrameworkTags: [String] = []
    
    @Published var abstractUrls: [String] = []

    @Published var username = ""
    @Published var fullname = ""
    @Published var bio = ""

    private var uiProfileImage: UIImage?
    private var uiBackgroundImage: UIImage?

    private var cancellables = Set<AnyCancellable>()

    init() {
        if let currentUser = AuthService.shared.currentUser {
            self.user = currentUser
        } else {
            self.user = User(id: "", uid: "", username: "", email: "", isPrivate: false, connectList: [], snsLinks: [:])
        }
        setupSubscribers()
        Task {
            try await loadLanguageTags()
            try await loadFrameworkTags()
        }
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
    func loadLanguageTags() async throws {
        do {
            let fetchedLanguageTags = try await UserService.fetchLanguageTags(withUid: user.id)
            self.selectedLanguageTags = fetchedLanguageTags.tags
        } catch {
            print("Failed to fetch tags: \(error)")
        }
    }

    func updateLanguageTags() async throws {
        try await UserService.saveLanguageTags(userId: user.id, selectedTags: selectedLanguageTags)
    }
    
    @MainActor
    func loadFrameworkTags() async throws {
        do {
            let fetchedFrameworkTags = try await UserService.fetchFrameworkTags(withUid: user.id)
            self.selectedFrameworkTags = fetchedFrameworkTags.tags
        } catch {
            print("Failed to fetch tags: \(error)")
        }
    }
    
    func updateFrameworkTags() async throws {
                try await UserService.saveFrameworkTags(userId: user.id, selectedTags: selectedFrameworkTags)
    }
    
    @MainActor
    func loadAbstractLinks() async {
        do {
            let fetchedAbstractUrls = try await UserService.fetchAbstractLinks(withUid: user.id)
            self.abstractUrls = fetchedAbstractUrls
        } catch {
            print("Failed to fetch abstract links: \(error)")
        }
    }

    @MainActor
    //Firebase Databaseのユーザ情報を変更する関数
    func updateUserData() async throws {
        //update profile image if changed
        var data = [String: Any]() //keyがString型，valueがAnyの辞書を定義

        if let uiImage = uiProfileImage {
            let imageUrl = try await ImageUploader.uploadImage(image: uiImage) //String型の画像のダウンロードURLが返される．
            data["profileImageUrl"] = imageUrl //辞書に格納
        }

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
