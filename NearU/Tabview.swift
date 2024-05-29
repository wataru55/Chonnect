//
//  Tabview.swift
//  NearU
//
//  Created by  髙橋和 on 2024/02/27.
//

import SwiftUI

struct Tabview: View {
    var body: some View {
        TabView {
            Text("homeview")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                Text("ProfileTab")
                    .tabItem {
                        Image(systemName: "person")
                        Text("myprofile")
                    }
                Text("お気に入りTab")
                    .tabItem {
                        Image(systemName: "heart")
                        Text("myprofile")
                    }
                Text("設定Tab")
                    .tabItem {
                        Image(systemName: "gear")
                        Text("setting")
                    }
            }
    }
}

#Preview {
    Tabview()
}
