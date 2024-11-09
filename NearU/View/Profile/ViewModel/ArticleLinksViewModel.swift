//
//  AbstractLinksViewModel.swift
//  NearU
//
//  Created by 谷口右京 on 2024/10/16.
//

import Foundation
import Firebase
import OpenGraph

class AbstractLinksViewModel: ObservableObject {
    @Published var openGraphData: [OpenGraph] = []
    @Published var article_urls: [String] = []

    func fetchArticleUrls() {
        
    }
}
