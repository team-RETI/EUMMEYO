//
//  EUMMEYOApp.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/19/24.
//

import SwiftUI

@main
struct EUMMEYOApp: App {

    // 다크모드 상태 저장
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // 파이어베이스 초기화
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 의존성 주입
    @StateObject var container: DIContainer = .init(services: Services())
        
    var body: some Scene {
        WindowGroup {
            AuthenticationView(authViewModel: .init(container: container))
                .environmentObject(container)
                .preferredColorScheme(isDarkMode ? .dark : .light)  // 다크모드 적용
        }
    }
}
