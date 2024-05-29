//
//  MainTabView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/15.
//

import SwiftUI

struct MainTabView: View {
    //MARK: - property
    let user: User

    @StateObject private var centralManager : BLECentralManager
    @StateObject private var peripheralManager : BLEPeripheralManager

    init(user: User) {
        _centralManager = StateObject(wrappedValue: BLECentralManager(user: user))
        _peripheralManager = StateObject(wrappedValue: BLEPeripheralManager(user: user))
        self.user = user
    }
//    init() {
//        UITabBar.appearance().backgroundColor = .gray
//        UITabBar.appearance().unselectedItemTintColor = .white
//    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            PostView()
                .tabItem {
                    Image(systemName: "plus.app")
                    Text("Post")
                }

            CurrentUserProfileView(user: user)
                .tabItem {
                    Image(systemName: "person")
                    Text("MyGallery")
                }

            SettingView(user: user)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setting")
                }
        }
        .accentColor(Color(.systemMint))

    } //body
}//view

#Preview {
    MainTabView(user: User.MOCK_USERS[0])
}

