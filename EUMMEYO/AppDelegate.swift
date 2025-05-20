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

class AppDelegate: NSObject, UIApplicationDelegate {
    // Firebase
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        MobileAds.shared.start()
        print("admob 초기화")
        return true
    }
    
    // Google Login
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
