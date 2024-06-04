//
//  SNSButtonView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/06/03.
//

import SwiftUI

struct SNSButtonView: View {
    var body: some View {
        Button {

        } label: {
            ZStack {
                Image("YouTube")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 100)
                    .cornerRadius(12)
                    .clipped()
                    .opacity(0.7)

                Text("YouTube")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
            }
        }

    }
}

#Preview {
    SNSButtonView()
}
