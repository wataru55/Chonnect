//
//  LaunchScreenView.swift
//  NearU
//
//  Created by  渡辺翼 on 2024/11/2.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isActive = false
    @State private var isTextVisible = false
    @State private var size: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    
    var body: some View {
        if isActive {
            ContentView() // コンテンツの表示
        } else {
            VStack {
                VStack {
                    Image("Chonnect")
                        .resizable()
                        .frame(width: 300, height: 50)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            // ロゴアニメーション
                            withAnimation(.easeOut(duration: 1.0)) {
                                self.size = 0.9
                                self.opacity = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    self.isTextVisible = true
                                }
                            }
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
