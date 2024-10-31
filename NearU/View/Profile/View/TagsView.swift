//
//  TagsView.swift
//  NearU
//
//  Created by Tsubasa Watanabe on 2024/10/15.
//

import SwiftUI

struct TagsView: View {
    var tags: [String]
    //let userId: String

    var body: some View {
        VStack {
            if tags.isEmpty {
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(15)
                        }
                    }
                    .padding(5)
                }
                .frame(height: 35)
            }
        }
    }
}
