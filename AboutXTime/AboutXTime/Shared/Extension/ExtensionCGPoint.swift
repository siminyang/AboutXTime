//
//  ExtensionCGPoint.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/20.
//

import Foundation

extension CGPoint {
    // 計算兩個點之間的距離
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2)) - 20
    }
}
