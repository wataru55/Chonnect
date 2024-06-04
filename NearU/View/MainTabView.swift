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

    @StateObject var centralManager : BLECentralManager
    @StateObject var peripheralManager : BLEPeripheralManager

    init(user: User) {
        self.user = user
        self._centralManager = StateObject(wrappedValue: BLECentralManager(user: user))
        self._peripheralManager = StateObject(wrappedValue: BLEPeripheralManager(user: user))
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            SearchView(currentUser: user)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
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

