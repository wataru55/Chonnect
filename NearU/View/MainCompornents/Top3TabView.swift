//
//  Top3TabView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/24.
//

import SwiftUI

struct Top3TabView: View {
    var body: some View {
        HStack {
            HStack(spacing: -10) {
                Image("Python")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .clipShape(Circle())
                    .zIndex(2)
                    .background (
                        Circle().fill()
                            .foregroundStyle(.white)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    )
                    .overlay(alignment: .top) {
                        Image(systemName: "crown.fill")
                            .font(.footnote)
                            .foregroundStyle(.yellow)
                            .offset(y: -10)
                    }

                Image("Swift")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .clipShape(Circle())
                    .zIndex(1)
                    .background (
                        Circle().fill()
                            .foregroundStyle(.white)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    )
                    .overlay(alignment: .top) {
                        Image(systemName: "crown.fill")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .offset(y: -10)
                    }

                Image("Ruby")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .clipShape(Circle())
                    .background (
                        Circle().fill()
                            .foregroundStyle(.white)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    )
                    .overlay(alignment: .top) {
                        Image(systemName: "crown.fill")
                            .font(.footnote)
                            .foregroundStyle(.brown)
                            .offset(y: -10)
                    }
            }
            .frame(height: 60)

            Text("... 一覧を表示")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    Top3TabView()
}
