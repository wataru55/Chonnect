//
//  SNSLinkButtonView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/14.
//

import SwiftUI

struct SNSLinkButtonView: View {
    @State var selectedSNS: String
    @State var sns_url: String
    let frontGradientView: LinearGradient = LinearGradient(gradient: Gradient(colors: [.yellow, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
    let backGradientView: LinearGradient = LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
    let bgColor = Color.init(red: 0.92, green: 0.93, blue: 0.94)
    let grayColor = Color.init(white: 0.8, opacity: 1)

    var body: some View {
        ZStack {
            // whiteの影を使うため若干グレーがかった背景を使う
            bgColor.ignoresSafeArea()
            
            Button(action: {
                if let url = URL(string: sns_url) {
                    UIApplication.shared.open(url)
                }
            }) {
                VStack {
                    Image(selectedSNS)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .frame(width: 80, height: 80)
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
                .background(
                    Circle() // 形状をCircleに変更
                        .foregroundStyle(bgColor)
                        // 上側の凸をshadowで表現
                        .shadow(color: .white, radius: 5, x: -7, y: -7)
                        // 下側の凸をshadowで表現
                        .shadow(color: grayColor, radius: 5, x: 7, y: 7)
                )
                .overlay(
                    Circle() // ここもCircleに変更
                        .stroke(.gray, lineWidth: 0)
                )
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 8)
        }

    }
}

#Preview {
    SNSLinkButtonView(selectedSNS: "Instagram", sns_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr")
}
