//
//  AppDelegate.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/22/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import GoogleSignIn
import GoogleMobileAds
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    // Firebase
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        MobileAds.shared.start()
        
        // 앱 실행 시 사용자에게 알림 허용 권한 받기
        UNUserNotificationCenter.current().delegate = self
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        // 알림 권한 호출
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // print("✅ 알림 권한: \(granted)")
            guard granted else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        return true
    }
    
    // Google Login
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    // Background 녹음
    func applicationDidBecomeActive(_ application: UIApplication) {
        AudioRecorderRepository.shared.resumeIfRecording()
    }
}

// MARK: - 알람관련
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // 1) Data → 16진수 문자열 변환
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let tokenString = tokenParts.joined()
        // print("APNS token: \(tokenString)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 포그라운드(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔥 받은 FCM 토큰: \(String(describing: fcmToken))")
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "localFCMToken")
        }
    }
}




///// UserDefault 저장
//UserDefaults.standard.set(user.isPushEnabled, forKey: "pushEnabled")
