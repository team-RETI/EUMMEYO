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
    // MARK: - 기준 기기 (default: iPhone 15 Pro Max)
    private static var baseSize: CGSize = BaseDevice.iPhone15ProMax.size
    private static var bounds: CGRect = CGRect(origin: .zero, size: baseSize)

    /// 앱 시작 시, 현재 디바이스 screen bounds 및 기준 디바이스를 설정
    public static func setScreenSize(_ newBounds: CGRect, baseDevice: BaseDevice = .iPhone15ProMax) {
        self.bounds = newBounds
        self.baseSize = baseDevice.size
    }

    /// 현재 기기 화면 너비
    public static var screenWidth: CGFloat { bounds.width }

    /// 현재 기기 화면 높이
    public static var screenHeight: CGFloat { bounds.height }

    /// 전체 bounds
    public static var screenBounds: CGRect { bounds }

    /// 현재 기기의 대각선 기반 스케일 비율
    public static var scaleFactor: CGFloat {
        let currentDiagonal = sqrt(screenWidth * screenWidth + screenHeight * screenHeight)
        let baseDiagonal = sqrt(baseSize.width * baseSize.width + baseSize.height * baseSize.height)
        return currentDiagonal / baseDiagonal
    }

    /// 주어진 값에 스케일 비율을 적용 (동적 크기 계산)
    public static func scaledSize(_ size: CGFloat) -> CGFloat {
        return size * scaleFactor
    }
}
