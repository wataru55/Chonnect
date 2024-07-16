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
                Rectangle()
                    .frame(width: 180, height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .foregroundStyle(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .padding(.horizontal, 10)

                VStack {
                    HStack{
                        Image(selectedSNS)
                            .resizable()
                            .frame(width: 50, height: 50)

                        Spacer()
                    }
                    .frame(width: 150, height: 100)

                    Text(selectedSNS)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .padding(.top, 10)

                    Spacer()

                    HStack {
                        Text("Touch me")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)

                        Image(systemName: "hand.tap.fill")
                            .foregroundStyle(.black)
                    }
                    .padding(.bottom)
                }
                .frame(width: 150, height: 240)

            }
        })
    }
}

#Preview {
    SNSLinkButtonView(selectedSNS: "Instagram", sns_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr")
}
