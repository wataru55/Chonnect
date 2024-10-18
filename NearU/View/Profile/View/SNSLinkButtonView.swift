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

    var body: some View {
        Button(action: {
            if let url = URL(string: sns_url) {
                UIApplication.shared.open(url)
            }

        }, label: {
            ZStack {
                Circle()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.white)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    )


                VStack {
                    VStack{
                        Image(selectedSNS)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .frame(width: 100, height: 100)
                }
                .frame(width: 70, height: 70)

            }
        })
    }
}

#Preview {
    SNSLinkButtonView(selectedSNS: "Instagram", sns_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr")
}
