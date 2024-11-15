import SwiftUI

struct SNSLinkButtonView: View {
    @EnvironmentObject var viewModel: EditSNSLinkViewModel
    @State private var isShowAlert: Bool = false
    let selectedSNS: String
    let sns_url: String
    let isShowDeleteButton: Bool
    let backgroundColor: Color = Color(red: 0.96, green: 0.97, blue: 0.98) // デフォルトの背景色
    let grayColor = Color.init(white: 0.8, opacity: 1)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea() // 指定された背景色を適用

            ZStack (alignment: .topTrailing){
                Button {
                    if let url = URL(string: sns_url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    VStack {
                        customImageBuilder(name: selectedSNS)
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

                if isShowDeleteButton {
                    Button {
                        isShowAlert.toggle()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.black)
                            .font(.title2)
                    }
                    .alert("確認", isPresented: $isShowAlert) {
                        Button("削除", role: .destructive) {
                            Task {
                                try await viewModel.deleteSNSLink(serviceName: selectedSNS, url: sns_url)
                                await viewModel.loadSNSLinks()
                                await MainActor.run {
                                    isShowAlert.toggle()
                                }
                            }
                        }
                    } message: {
                        Text("このリンクを削除しますか？")
                    }
                }
            }
        }
    }

    @ViewBuilder
    func customImageBuilder(name: String) -> some View {
        if name == "link" {
            Image(systemName: "link")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.black)
        } else {
            Image(selectedSNS)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    SNSLinkButtonView(selectedSNS: "Instagram",
                      sns_url: "https://www.instagram.com/wataw.ataaa?igsh=MXEwNjhha2dwbHM2dQ%3D%3D&utm_source=qr",
                      isShowDeleteButton: true)
    .environmentObject(EditSNSLinkViewModel())
}

