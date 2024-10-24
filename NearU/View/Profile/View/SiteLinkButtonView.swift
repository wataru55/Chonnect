//
//  SiteLinkButtonView.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/07.
//

import SwiftUI

struct SiteLinkButtonView: View {
    let abstract_title: String
    let abstract_url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: abstract_url) {
                UIApplication.shared.open(url)
            }
        }, label: {
            Text(abstract_title)
                .frame(width: 350, height: 70) // ボタンサイズの調整
                .background(Color(red: 0.92, green: 0.93, blue: 0.94)) // ボタン背景色
                .foregroundColor(.black) // テキスト色
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 1) // 枠線を設定
                )
        })
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 10)
    }
}


#Preview {
    SiteLinkButtonView(abstract_title: "test", abstract_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr")
}
