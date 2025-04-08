//
//  SiteLinkButtonView.swift
//  NearU
//
//  Created by 渡辺翼 on 2024/11/02.
//

import SwiftUI
import OpenGraph

struct SiteLinkButtonView: View {
    @EnvironmentObject var viewModel: ArticleLinksViewModel
    @State private var isShowAlert: Bool = false
    let ogpData: OpenGraphData
    let _width: CGFloat
    let _height: CGFloat
    var showDeleteButton: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                if let url = URL(string: ogpData.url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                VStack(alignment: .leading) {
                    if let data = ogpData.openGraph {
                        // メタデータが取得できた場合のリンクプレビュー
                        VStack(alignment: .center, spacing: 20) {
                            if let imageUrl = data[.image], let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.gray.frame(height: 100).cornerRadius(10)
                                }
                            } else {
                                Image(systemName: "network")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 20)
                            }
                            
                            VStack(spacing: 5) {
                                if let type = data[.type], !type.isEmpty {
                                    Text(type)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("unknown")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                if let title = data[.title], !title.isEmpty {
                                    Text(title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .lineLimit(3)
                                } else {
                                    Text(ogpData.url)
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                        .lineLimit(3)
                                }
                            }
                            .padding(.horizontal, 5)
                            
                            Spacer()
                        }// Vstack
                        .frame(width: _width, height: _height)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray, radius: 2, x: 1, y: 1)
                        .padding()
                    }
                } //vstack
            } //button
            .buttonStyle(PlainButtonStyle())

            if showDeleteButton {
                Button {
                    isShowAlert.toggle()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .padding()
                }
                .alert("確認", isPresented: $isShowAlert) {
                    Button("削除", role: .destructive) {
                        Task {
                            await viewModel.removeArticle(url: ogpData.url)
                            await MainActor.run {
                                isShowAlert.toggle()
                            }
                        }
                    }
                } message: {
                    Text("このリンクを削除しますか？")
                }
            }
        } //zstack
    }//body
} //view
