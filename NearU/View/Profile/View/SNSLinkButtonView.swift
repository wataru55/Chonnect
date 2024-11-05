import SwiftUI

struct SNSLinkButtonView: View {
    @State var selectedSNS: String
    @State var sns_url: String
    var backgroundColor: Color = Color(red: 0.92, green: 0.93, blue: 0.94) // デフォルトの背景色

    let grayColor = Color.init(white: 0.8, opacity: 1)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea() // 指定された背景色を適用

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
                    Circle()
                        .foregroundStyle(backgroundColor)
                        .shadow(color: .white, radius: 5, x: -7, y: -7)
                        .shadow(color: grayColor, radius: 5, x: 7, y: 7)
                )
                .overlay(
                    Circle()
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

