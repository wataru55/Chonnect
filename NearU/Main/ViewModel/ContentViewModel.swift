//
//  ContentViewModel.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import Foundation
import FirebaseAuth

import Combine //非同期処理とデータの処理を宣言的に扱うためのフレームワーク

//Firebaseの認証情報を利用してユーザーセッションの状態を監視するクラス
class ContentViewModel: ObservableObject { //SwiftUIがデータの変化を検知し、Viewを更新するためのプロトコル
    //MARK: - property
    private let service = AuthService.shared //.sharedによってserviceがただ唯一のAuthServiceのインスタンスであることを保証し，どこからでもserviceでアクセスできる
    private var cancellables = Set<AnyCancellable>() //Combineの購読を管理するためのセット.購読を解除する際に使用

    @Published var userSession: FirebaseAuth.User? //@Published: このプロパティの値が変わると、このプロパティを監視しているViewが更新
    @Published var currentUser: User?

    //MARK: - init
    init() { //ViewModelが生成されるときにsetupSubscribers()を呼び出して購読を設定
        setupSubscribers()
    }

    //MARK: - function
    func setupSubscribers() {
        service.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] userSession in //1.userSessionプロパティが持つPublisherにアクセス, 2.　.sinkでPublisherからデータ(userSession)を受け取る
            self?.userSession = userSession
        }
        .store(in: &cancellables) //作成されたサブスクリプション（購読）を管理

        service.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] currentUser in //1.userSessionプロパティが持つPublisherにアクセス, 2.　.sinkでPublisherからデータ(userSession)を受け取る
            self?.currentUser = currentUser
        }
        .store(in: &cancellables) //作成されたサブスクリプション（購読）を管理
    }//setupSubscribers

    func forceSignout() {
        service.signout()
        print("ユーザデータが見つかりませんでした")
    }

}//class
