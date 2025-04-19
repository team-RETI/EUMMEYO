//
//  DynamicSize.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/19/25.
//

import Foundation

/**
 🧩 DynamicSize 사용법 안내

 다양한 iPhone 기기에서 화면 크기에 따라
 텍스트, 패딩, 뷰 크기 등을 자동으로 스케일링 해주는 유틸리티입니다.
 기준 기기는 iPhone 15 Pro Max (430 x 932pt)입니다.

 📐 내부 계산 공식:
 1. currentDiagonal = √(기기 width² + 기기 height²)
 2. baseDiagonal = √(430² + 932²)
 3. scaleFactor = currentDiagonal / baseDiagonal
 4. 최종 크기 = baseSize × scaleFactor

 📌 UIKit 사용 예시:
 label.font = .systemFont(ofSize: DynamicSize.scaledSize(18))
 view.layer.cornerRadius = DynamicSize.scaledSize(12)
 view.snp.makeConstraints { $0.height.equalTo(DynamicSize.scaledSize(50)) }

📌 SwiftUI 사용 예시:
 Text("시작하기")
     .font(.system(size: DynamicSize.scaledSize(18)))
     .padding(DynamicSize.scaledSize(16))
     .frame(height: DynamicSize.scaledSize(50))
     .background(Color.green)
     .cornerRadius(DynamicSize.scaledSize(12))

 ✅ 주의: 앱 시작 시점(SceneDelegate 등)에서 아래 함수 필수 호출
 DynamicSize.setScreenSize(UIScreen.main.bounds)
*/

// MARK: - 기기별 화면 크기에 따라 UI 크기를 동적으로 조절하기 위한 유틸리티
/// 기준 기기 (15 Pro Max) 기준으로 다른 기기에서 비율을 계산하여 `글자 크기`, `여백`, `뷰 크기` 등을 조정할 때 사용가능
struct DynamicSize {
    /// 기준 너비 (15 Pro Max)
    private static let baseWidth: CGFloat = 430
    
    /// 기준 높이 (15 Pro Max)
    private static let baseHeight: CGFloat = 932
    
    /// 기준 대각선 길이  (15 Pro Max)
    private static let baseDiagonal: CGFloat = sqrt(baseWidth * baseWidth + baseHeight * baseHeight)
    
    /// 화면 크기 저장 (기본값 430 * 932)
    ///
    ///  - Note: `SceneDelegate`에서 `setScreenSize(_:)`를 호출 필요
    private static var bounds: CGRect = CGRect(x: 0, y: 0, width: baseWidth, height: baseHeight)
    
    /// 전체 화면 크기 설정
    ///
    /// - Parameter newBounds: 새롭게 설정할 화면의 `CGRect`크기
    static func setScreenSize(_ newBounds: CGRect) {
        self.bounds = newBounds
    }
    
    /// 기기 화면 너비
    static var screenWidth: CGFloat {
        return bounds.width
    }
    
    /// 기기 화면 높이
    static var screenHeight: CGFloat {
        return bounds.height
    }
    
    /// 기기 화면 전체 크기
    static var screenBounds: CGRect {
        return bounds
    }
}

extension DynamicSize {
    
    /// 현재 기기의 대각선 기반 스케일 비율 (현재 기기의 대각선 / 기존 기기의 대각선)
    static var scaleFactor: CGFloat {
        let currentDiagonal = sqrt(screenWidth * screenWidth + screenHeight * screenHeight)
        return currentDiagonal / baseDiagonal
    }
    
    /// 주어진 값에 스케일 비율을 적용(동적 크기 계산)
    static func scaledSize(_ size: CGFloat) -> CGFloat {
        print("test: \(size * scaleFactor)")
        return size * scaleFactor
    }
}
