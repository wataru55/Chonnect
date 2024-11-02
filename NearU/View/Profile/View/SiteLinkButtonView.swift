//
//  SiteLinkButtonView.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/07.
//

import SwiftUI
import LinkPresentation

struct SiteLinkButtonView: View {
    let abstract_title: String
    let abstract_url: String
    @State private var metadata: LPLinkMetadata?
    
    var body: some View {
        VStack {
            if let metadata = metadata {
                LinkPreview(metadata: metadata)
                    .frame(width: 350, height: 150)
            } else {
                Button(action: {
                    if let url = URL(string: abstract_url) {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    Text(abstract_title.count > 35 ? String(abstract_title.prefix(35)) + "..." : abstract_title)
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
        .padding(.bottom, 10)
    }
    
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

struct LinkPreview: UIViewRepresentable {
    let metadata: LPLinkMetadata
    
    func makeUIView(context: Context) -> LPLinkView {
        return LPLinkView(metadata: metadata)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {}
}

#Preview {
    SiteLinkButtonView(abstract_title: "test", abstract_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr")
}
