//
//  ExtensionColor.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/19.
//

import SwiftUI

enum STColor: String {
    case CC1 = "#B026FF" // 霓虹紫
    case CC2 = "#7df9ff" // 霓虹藍
    case CC3 = "#ffff33" // 霓虹黃
    case CC4 = "#ff00ff" // 霓虹粉
    case CC5 = "#FF5E00" // 霓虹橘
}

extension STColor {
    var color: Color {
        return Color.hex(self.rawValue)
    }

    var uiColor: UIColor {
        return UIColor.hex(self.rawValue)
    }
}

extension Color {
    static func hex(_ hex: String) -> Color {
        let cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard cleanedHex.hasPrefix("#") else {
            return Color.gray
        }

        let hexWithoutHash = String(cleanedHex.dropFirst())

        guard hexWithoutHash.count == 6 else {
            return Color.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexWithoutHash).scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}

extension UIColor {
    static func hex(_ hex: String) -> UIColor {
        let cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard cleanedHex.hasPrefix("#") else {
            return UIColor.gray
        }

        let hexWithoutHash = String(cleanedHex.dropFirst())

        guard hexWithoutHash.count == 6 else {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexWithoutHash).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
