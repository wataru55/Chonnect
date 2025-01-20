//
//  KalmanFilter.swift
//  NearU
//
//  Created by 高橋和 on 2025/01/14.
//

import Foundation

class KalmanFilter {
    private var currentEstimate: Double // 現在の推定値
    private var processNoise: Double = 1.0 // プロセスノイズ（システムの変動）
    private var measurementNoise: Double = 6.0 // 観測ノイズ
    private var estimatedError: Double =  5.0 // 推定誤差
    
    init(initialEstimate: Double) {
        self.currentEstimate = initialEstimate
    }
    
    func smoothing(measurement: Double) -> Double {
        // カルマンゲインを計算
        let kalmanGain = estimatedError / (estimatedError + measurementNoise)
        
        // 推定値を更新
        currentEstimate = currentEstimate + kalmanGain * (measurement - currentEstimate)
        
        // 推定誤差を更新
        estimatedError = (1 - kalmanGain) * estimatedError + processNoise
        
        return currentEstimate
    }
}
