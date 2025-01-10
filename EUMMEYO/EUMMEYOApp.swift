//
//  EUMMEYOApp.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/19/24.
//

import SwiftUI

@main
struct EUMMEYOApp: App {

    
    // 파이어베이스 초기화
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 의존성 주입
    @StateObject var container: DIContainer = .init(services: Services())

    var body: some Scene {
        WindowGroup {
            // MaintabView()
            AuthenticationView(authViewModel: .init(container: container))
                .environmentObject(container)
        }
    }
}
