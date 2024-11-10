//
//  SiteLinkButtonView.swift
//  NearU
//
//  Created by 渡辺翼 on 2024/11/02.
//

import SwiftUI
import OpenGraph

struct SiteLinkButtonView: View {
    let ogpData: OpenGraphData
    var showDeleteButton: Bool

    var body: some View {
        Button {
            if let url = URL(string: ogpData.url) {
                UIApplication.shared.open(url)
            }
        }label: {
            VStack(alignment: .leading) {
                if let data = ogpData.openGraph {
                    // メタデータが取得できた場合のリンクプレビュー
                    VStack(alignment: .leading) {
                        if let imageUrl = data[.image], let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 100)
                                    .cornerRadius(10)
                            } placeholder: {
                                Color.gray.frame(height: 100).cornerRadius(10)
                            }
                        }
                        // タイトルがない場合はurlを表示
                        if let title = data[.title], !title.isEmpty {
                            Text(title)
                                .font(.headline)
                                .lineLimit(1)
                        } else {
                            Text(ogpData.url.count > 35 ? String(ogpData.url.prefix(35)) + "..." : ogpData.url)
                                .font(.headline)
                                .lineLimit(1)
                                .padding(.bottom, 2)
                        }
                        //.padding(.leading, 15)
                    }// Vstack
                    .padding()
                    .frame(width: 350, height: 150, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                } //vstack
            } //vstack
        } //button
        .buttonStyle(PlainButtonStyle())
    }//body
} //view

