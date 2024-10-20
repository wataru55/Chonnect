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
                .frame(width: 300, height: 70) // ボタンサイズの調整
                .background(Color.white) // ボタン背景色
                .foregroundColor(.black) // テキスト色
                .clipShape(RoundedCorners(radius: 100, corners: [.topLeft, .bottomLeft]))
                .overlay(
                    RoundedCorners(radius: 100, corners: [.topLeft, .bottomLeft])
                        .stroke(Color.black, lineWidth: 1) // 枠線を設定
                )
        })
        .buttonStyle(PlainButtonStyle())
    }
}

struct RoundedCorners: Shape {
    var radius: CGFloat = 10
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


#Preview {
    SiteLinkButtonView(abstract_title: "test", abstract_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr")
}
