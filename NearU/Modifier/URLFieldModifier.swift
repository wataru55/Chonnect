//
//  URLFieldModifier.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/11/09.
//

import SwiftUI

struct URLFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.never) // 自動で大文字にしない
            .disableAutocorrection(true) // スペルチェックを無効にする
            .font(.subheadline)
            .padding(10)
    }
}
