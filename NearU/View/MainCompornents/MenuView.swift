//
//  MenuView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/07/19.
//

import SwiftUI

struct MenuView: View {
    /// メニュー開閉
    @Binding var isOpen: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
                .opacity(isOpen ? 0.7 : 0)
                .onTapGesture {
                    /// isOpenの変化にアニメーションをつける
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isOpen.toggle()
                    }
                }
            ZStack {
                Color.gray.opacity(0.7)
                    .cornerRadius(20.0)

                VStack{
                    Button(action: {
                        AuthService.shared.signout()
                    }, label: {
                        Text("Log out")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .frame(width: 200, height: 44)
                            .background(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.gray)
                            )
                    })
                    .padding(.top, 30)

                    Spacer()
                }//vstack
            }//zstack
            /// 画面幅の1/3だけ左側を開ける
            .padding(.leading, UIScreen.main.bounds.width/3)
            /// isOpenで、そのままの位置か、画面幅だけ右にズレるかを決める
            .offset(x: isOpen ? 0 : UIScreen.main.bounds.width)
        }
    }
}

#Preview {
    MenuView(isOpen: .constant(true))
}
