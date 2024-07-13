//
//  EditProfileViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/17.
//

import PhotosUI
import SwiftUI
import Firebase

class EditProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var selectedImage: PhotosPickerItem? { //PhotosPickerから選択されたアイテムを保持するプロパティ
        //didset:プロパティの値が変更された直後に呼び出される．
        didSet { Task { await loadImage(fromItem: selectedImage) }}
    }

    @Published var profileImage: Image?

    @Published var fullname = ""
    @Published var bio = ""

    private var uiImage: UIImage?

    init(user: User) {
        self.user = user

        if let fullname = user.fullname {
            self.fullname = fullname
        }

        if let bio = user.bio {
            self.bio = bio
        }
    }

    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return } //オプショナルでないか確認
        //データを読み込みバイナリデータとして取得
        guard let data = try? await item.loadTransferable(type: Data.self) else { return } 
        //バイナリデータをUIImage型に変換
        guard let uiImage = UIImage(data: data) else { return } //バイナリデータが有効な画像データであるか検証するため
        self.uiImage = uiImage
        //UIImage(画像の操作に使われる型)をImage型（SwiftUI の画像表示用オブジェクト）に変換．
        self.profileImage = Image(uiImage: uiImage)
    }
    @MainActor
    //Firebase Databaseのユーザ情報を変更する関数
    func updateUserData() async throws {
        //update profile image if changed
        var data = [String: Any]() //keyがString型，valueがAnyの辞書を定義

        if let uiImage = uiImage {
            let imageUrl = try await ImageUploader.uploadImage(image: uiImage) //String型の画像のダウンロードURLが返される．
            data["profileImageUrl"] = imageUrl //辞書に格納
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
