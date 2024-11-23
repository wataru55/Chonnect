//
//  WordCloudView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/19.
//

import SwiftUI

struct WordCloudView: View {
    private let words: [WordElement] = [WordElement].generate(forSwiftUI: true)
    private var positionCache = WordCloudPositionCache()

    @State private var canvasRect = CGRect()
    @State private var wordSizes: [CGSize]

    init() {
        self._wordSizes = State(initialValue:[CGSize](repeating: CGSize.zero, count: words.count))
    }

    var body: some View {
        let pos = calcPositions(canvasSize: canvasRect.size, itemSizes: wordSizes)

        ZStack{
            ForEach(Array(words.enumerated()), id: \.offset) {idx, word in
                NavigationLink(destination: Text("\(word.name)")) {
                    Text("\(word.name)")
                        .foregroundStyle(.black)
                        .font(.subheadline)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(3)
                        .background(WordSizeGetter($wordSizes, idx))
                }
                .position(x: canvasRect.width/2 + pos[idx].x,
                          y: canvasRect.height/2 + pos[idx].y)

            }
        }
        .background(RectGetter($canvasRect))
    }

    // 矩形同士が重なっているかどうかを判定
    func checkIntersects(rect: CGRect, rects: [CGRect]) -> Bool {
        for r in rects {
            if rect.intersects(r) {
                return true
            }
        }
        return false
    }

    // SwiftUIの微小な調整による誤差を無視する
    func simularWordSizes(a: [CGSize], b: [CGSize]) -> Bool {
        if a == b {
            return true
        }

        if a.count != b.count {
            return false
        }
        var diff : CGFloat = 0
        for i in 0...(a.count-1) {
            diff += abs(a[i].width - b[i].width) +
            abs(a[i].height - b[i].height)
        }

        return diff < 0.01
    }

    // 矩形がキャンバスの境界外に出ているかどうかを判定
    func checkOutsideBoundry(canvasSize: CGSize, rect: CGRect) -> Bool {
        if rect.maxY > canvasRect.height/2 {
            return true
        }
        if rect.minY < -canvasRect.height/2 {
            return true
        }
        return false
    }

    // 単語の配置をスパイラルパスに基づいて計算する
    func calcPositions(canvasSize: CGSize, itemSizes: [CGSize]) -> [CGPoint] {
        var pos = [CGPoint](repeating: CGPoint.zero, count: itemSizes.count)
        if canvasSize.height == 0 {
            return pos
        }

        // キャッシュが有効な場合はキャッシュを返す
        if positionCache.canvasSize == canvasSize
            && simularWordSizes(a: positionCache.wordSizes, b: wordSizes) {
            return positionCache.positions
        }

        // deferによって関数の最後に実行され，キャッシュを更新する
        defer {
            positionCache.canvasSize = canvasSize
            positionCache.wordSizes = wordSizes
            positionCache.positions = pos
        }
        // 各単語の配置済み矩形を格納する配列.他の単語との衝突判定に使用
        var rects = [CGRect]()
        // スパイラル曲線をたどるためのステップ量（角度に相当）
        var step : CGFloat = 0
        // キャンバスのアスペクト比をもとに、スパイラル曲線の形状を調整
        let ratio = canvasSize.width * 1.5 / canvasSize.height
        // スパイラルの開始位置
        let startPos = CGPoint(x: CGFloat.random(in: 0...1) * canvasSize.width * 0.1,
                               y: CGFloat.random(in: 0...1) * canvasSize.height * 0.1)

        for (index, itemSize) in itemSizes.enumerated() {
            var nextRect = CGRect(origin: CGPoint(x: startPos.x - itemSize.width/2,
                                                  y: startPos.y - itemSize.height/2),
                                  size: itemSize)
            // スパイラル探索ロジック
            // stepがtに相当し，ratioが比率係数
            if index > 0 {
                // ループ条件：矩形がキャンバス外に出ないかつ，他の矩形と重ならない
                while checkOutsideBoundry(canvasSize: canvasSize,
                                          rect: nextRect)
                        || checkIntersects(rect: nextRect, rects: rects) {
                    nextRect.origin.x = startPos.x + ratio * step * cos(step) + startPos.x - itemSize.width/2
                    nextRect.origin.y = startPos.y + step * sin(step) + startPos.y - itemSize.height/2
                    step = step + 0.01
                }
            }
            pos[index] = nextRect.center
            rects.append(nextRect)
        }

        return pos
    }
}

// 各単語のキャッシュ
class WordCloudPositionCache {
    var canvasSize = CGSize.zero
    var wordSizes = [CGSize]()
    var positions = [CGPoint]()
}

extension CGRect {
    var center : CGPoint {
        return CGPoint(x: self.origin.x + self.size.width/2,
                       y: self.origin.y + self.size.height/2)
    }
}

// GeometryReader内部に透明な矩形を描画することでViewの要素の大きさ(CGSize)を取得する
struct WordSizeGetter: View {
    @Binding var sizeStorage: [CGSize]
    private var index: Int

    init(_ sizeStorage: Binding<[CGSize]>, _ index: Int) {
        _sizeStorage = sizeStorage
        self.index = index
    }

    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.sizeStorage[index] = proxy.frame(in: .global).size
        }

        return Rectangle().fill(Color.clear)
    }
}

// GeometryReader内部に透明な矩形を描画することでViewの要素の位置(CGRect)を取得する
struct RectGetter: View {
    @Binding var rect: CGRect

    init(_ rect: Binding<CGRect>) {
        _rect = rect
    }

    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}

#Preview {
    WordCloudView()
}
