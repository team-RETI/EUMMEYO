//
//  EUMMEYOApp.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/19/24.
//

import SwiftUI
import ScaleKit

@main
struct EUMMEYOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var container: DIContainer = .init(services: Services())

    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("jColor") private var jColor = 0

    @Environment(\.scenePhase) private var scenePhase
    @State private var didSetScreenSize = false

    var body: some Scene {
        WindowGroup {
            Group {
                if didSetScreenSize {
                    if isFirstLaunching {
                        OnboardingView(onboardingViewModel: .init())
                    } else {
                        AuthenticationView(authViewModel: .init(container: container))
                            .environmentObject(container)
                            .preferredColorScheme(isDarkMode ? .dark : .light)
                    }
                } else {
                    // 크기 설정 전에는 깜빡임 방지용 투명 화면
                    Color.clear
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active && !didSetScreenSize {
                    if let scene = UIApplication.shared.connectedScenes
                        .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                        print("✅ scenePhase .active - 화면 크기 적용됨: \(scene.screen.bounds)")
                        DynamicSize.setScreenSize(scene.screen.bounds)
                    } else {
                        print("⚠️ fallback: UIScreen.main.bounds")
                        DynamicSize.setScreenSize(UIScreen.main.bounds)
                    }
                    didSetScreenSize = true
                }
            }
        }
    }
}
