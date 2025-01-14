//
//  Extension+Color.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/30/24.
//

import SwiftUI

extension Color {
    /// RGB 값을 기반으로 Color를 생성합니다.
    /// - Parameters:
    ///   - red: 빨간색 값 (0~255)
    ///   - green: 초록색 값 (0~255)
    ///   - blue: 파란색 값 (0~255)
    ///   - opacity: 투명도 값 (기본값 1.0)
    init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: opacity
        )
    }
    
    /// RGB 값을 소수로 (0.0 ~ 1.0) Color를 생성합니다.
    /// - Parameters:
    ///   - red: 빨간색 값 (0.0 ~ 1.0)
    ///   - green: 초록색 값 (0.0 ~ 1.0)
    ///   - blue: 파란색 값 (0.0 ~ 1.0)
    ///   - opacity: 투명도 값 (기본값 1.0)
    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: opacity
        )
    }
    
    /// Hex 코드를 기반으로 Color 생성
    /// - Parameter hex: Hex 코드 (e.g., "#FF5733" 또는 "FF5733")
    init(hex: String) {
        // Remove `#` if included
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: Double
        switch hex.count {
        case 6: // RGB (e.g., FF5733)
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255.0,
                Double((int >> 8) & 0xFF) / 255.0,
                Double(int & 0xFF) / 255.0,
                1.0
            )
        case 8: // ARGB (e.g., FF5733FF)
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255.0,
                Double((int >> 8) & 0xFF) / 255.0,
                Double(int & 0xFF) / 255.0,
                Double((int >> 24) & 0xFF) / 255.0
            )
        default:
            (r, g, b, a) = (1, 1, 1, 1) // Default to white if invalid
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension Color {
    static let mainBlack = Color(hex: "#38383A")
    static let mainGray = Color(hex: "#D9D9D9")
    static let mainPink = Color(hex: "#fbbdba") // 메인 핑크 추가
    static let loginBlack = Color(hex: "#666666")
}
