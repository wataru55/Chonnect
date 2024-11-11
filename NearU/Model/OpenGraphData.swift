//
//  OpenGraphData.swift
//  NearU
//
//  Created by  髙橋和 on 2024/11/08.
//

import Foundation
import OpenGraph

struct OpenGraphData: Identifiable {
    let id = UUID()
    let url: String
    let openGraph: OpenGraph?
}
