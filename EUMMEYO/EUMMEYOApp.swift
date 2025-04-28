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
    @StateObject private var versionManager = VersionManager.shared

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
            .onAppear {
                versionManager.checkForAppUpdates(bundleId: "com.reti.EUMMEYO") // 여기 BundleID 주의!
            }
            .alert(isPresented: $versionManager.showUpdateAlert) {
                Alert(
                    title: Text("앱 업데이트 필요"),
                    message: Text("최신 버전 (\(versionManager.latestVersion ?? ""))으로 업데이트 해주세요!"),
                    dismissButton: .default(Text("업데이트")) {
                        if let url = URL(string: "https://apps.apple.com/app/id6738163114") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
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
