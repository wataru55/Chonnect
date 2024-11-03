//
//  SiteLinkButtonView.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/07.
//

import SwiftUI
import LinkPresentation

struct SiteLinkButtonView: View {
    let abstract_url: String
    @State private var metadata: LPLinkMetadata?
    
    var body: some View {
        VStack {
            if let metadata = metadata {
                // メタデータがある場合は OGP カードとして表示
                LinkPreview(metadata: metadata)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                // メタデータがない場合はボタンとして表示
                Button(action: {
                    if let url = URL(string: abstract_url) {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    Text(abstract_url.count > 35 ? String(abstract_url.prefix(35)) + "..." : abstract_url)
                        .padding(.leading, 15)
                        .frame(width: 350, height: 100, alignment: .leading)
                        .background(Color(red: 233 / 255, green: 233 / 255, blue: 235 / 255))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .lineLimit(1)
                        .truncationMode(.tail)
                })
                .buttonStyle(PlainButtonStyle())
                .onAppear {
                    fetchMetadata(for: abstract_url)
                }
            }
        }
    }
    
    // メタデータを取得する関数
    private func fetchMetadata(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata, error == nil {
                DispatchQueue.main.async {
                    self.metadata = metadata
                }
            }
        }
    }
}

// リンクのメタデータを表示するプレビュー用のビュー
struct LinkPreview: UIViewRepresentable {
    let metadata: LPLinkMetadata
    
    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(metadata: metadata)
        linkView.translatesAutoresizingMaskIntoConstraints = false
        return linkView
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        uiView.metadata = metadata
    }
}
