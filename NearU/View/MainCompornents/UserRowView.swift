//
//  UserRowView.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/15.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    let tags: [String]
    let date: Date?
    let rssi: Int?
    
    var body: some View {
        HStack(alignment: .center) {
            CircleImageView(user: user, size: .medium, borderColor: .clear)
            
            VStack(alignment: .leading, spacing: 5) {
                Attributes(attributes: user.attributes, option: AttributeOption.row)
                
                HStack {
                    Text(user.username)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, 5)
                    
                    Spacer()
                    
                    VStack {
                        if let rssi = rssi {
                            HStack(spacing: 4) {
                                Text("推定距離")
                                
                                Text(distance(fromRSSI: rssi))
                            }
                        }
                        
                        if let date = date {
                            HStack(spacing: 4) {
                                Text("最後のすれちがい")
                                
                                Text(formattedDate(from: date))
                            }
                        }
                    } //vstack
                    .font(.caption2)
                    .foregroundStyle(.gray)
                } //hstack
                
                if !tags.isEmpty {
                    InterestTagView(interestTags: tags, isShowDeleteButton: false, textFont: .caption)
                        .padding(.leading, 5)
                }
                
            }// vstack
        } //hstack
        .foregroundStyle(.black)
        .padding(.horizontal)
        .frame(height: 90)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .padding(.horizontal, 5)
                .foregroundStyle(.white)
                .shadow(color: .gray.opacity(0.5), radius: 2, x: 2, y: 2)
        )
    }
    
    // フォーマッターを追加
    private var standardDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private func formattedDate(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let day = components.day, day < 31 {
            if day >= 1 {
                return "\(day)日前"
            } else if let hour = components.hour, hour >= 1 {
                return "\(hour)時間前"
            } else if let minute = components.minute {
                return "\(minute)分前"
            } else {
                return "たった今"
            }
        } else {
            return standardDateFormatter.string(from: date)
        }
    }
    
    // RSSI値を基に距離を計算する関数
    func distance(fromRSSI rssi: Int) -> String {
        let txPower = -60 // デバイスの送信電力（RSSI値が1メートルの距離における理論的な値）。環境により調整が必要。
        let n = 2.0 // 環境による減衰係数（例：屋内では2.0、屋外では3.0）
        
        if rssi == 0 {
            return "距離不明"
        }
        
        // RSSIとtxPowerの差を計算
        let ratio = Double(txPower - rssi) / (10 * n)
        let distanceMeters = pow(10.0, ratio)
        
        // 距離をメートル単位で表示（小数点以下1桁）
        let formattedDistance = String(format: "%.1fメートル", distanceMeters)
        return formattedDistance
    }
}

#Preview {
    UserRowView(user: User.MOCK_USERS[0],
                tags: ["SwiftUI", "UIKit", "iOSDC"],
                date: Date(),
                rssi: nil,
    )
}
