//
//  ExpandableText.swift
//  NearU
//
//  Created by 高橋和 on 2025/07/10.
//

import SwiftUI

struct ExpandableText: View {
    
    // MARK: - サブタイプ
    struct Ellipsis {
        var text: String = "…"
        var color: Color = .primary
        var fontSize: CGFloat? = nil
    }
    
    // MARK: - Input
    private let text: String
    private let lineLimit: Int
    private let lineSpacing: CGFloat
    private let font: UIFont        // 計測用
    private let ellipsis: Ellipsis  // 末尾の「…」設定
    
    // MARK: - State
    @State private var isExpanded: Bool = false        // 展開／折りたたみ
    @State private var isTruncated: Bool = false       // 行数超過で省略されているか
    @State private var visibleText: String             // 折りたたみ時に表示するテキスト
    
    // MARK: - Init
    init(_ text: String,
         lineLimit: Int = 3,
         lineSpacing: CGFloat = 2,
         font: UIFont = .preferredFont(forTextStyle: .body),
         ellipsis: Ellipsis = Ellipsis()) {
        
        self.text         = text
        self.lineLimit    = lineLimit
        self.lineSpacing  = lineSpacing
        self.font         = font
        self.ellipsis     = ellipsis
        _visibleText      = State(initialValue: text)  // 初期値
    }
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            // --- 表示テキスト ---
            Group {
                if isExpanded {
                    // 全文表示
                    Text(text)
                } else {
                    // 折りたたみ表示（省略されている場合だけ「…」を付加）
                    Text(visibleText + (isTruncated ? ellipsis.text : ""))
                }
            }
            .font(Font(font))
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(.leading)
            .lineLimit(isExpanded ? nil : lineLimit)
            .background(
                // 背景で GeometryReader を使い、行数超過を測定
                Text(text)
                    .font(Font(font))
                    .lineLimit(lineLimit)
                    .lineSpacing(lineSpacing)
                    .foregroundColor(.clear)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { checkIfTruncated(within: geo.size.width) }
                        }
                    )
                    .hidden()
            )
            
            // --- ボタン ---
            if isTruncated {      // 省略されているときだけ表示
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Text(isExpanded ? "閉じる" : "全文を表示")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Private
    /// 与えられた幅で行数制限に収まるかを計算して isTruncated / visibleText を更新
    private func checkIfTruncated(within width: CGFloat) {
        // 1) 最初に“全文”が収まるかを計算
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let fullHeight = (text as NSString)
            .boundingRect(with: size,
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          attributes: attributes, context: nil)
            .height
        
        // lineLimit 行分の高さ (= 1 行の lineHeight × lineLimit)
        let lineHeight = font.lineHeight + lineSpacing
        let limitHeight = lineHeight * CGFloat(lineLimit)
        
        // 2) 行数オーバーか判定
        isTruncated = fullHeight > limitHeight + 0.5  // 誤差を考慮
        
        guard isTruncated else {
            // 省略されないなら visibleText は全文
            visibleText = text
            return
        }
        
        // 3) 二分探索で「表示できる最大文字数」を求める
        var low = 0
        var high = text.count
        var mid  = high
        
        while high - low > 1 {
            let trial = String(text.prefix(mid)) + ellipsis.text
            let trialHeight = (trial as NSString)
                .boundingRect(with: size,
                              options: [.usesLineFragmentOrigin, .usesFontLeading],
                              attributes: attributes, context: nil)
                .height
            
            if trialHeight > limitHeight {
                // 高さオーバー → 文字数を減らす
                high = mid
            } else {
                // まだ余裕 → 文字数を増やす
                low = mid
            }
            mid = (high + low) / 2
        }
        visibleText = String(text.prefix(low))
    }
}

//#Preview {
//    ExpandableText()
//}
