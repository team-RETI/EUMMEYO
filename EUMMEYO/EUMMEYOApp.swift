//
//  EUMMEYOApp.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/19/24.
//

import SwiftUI

@main
struct EUMMEYOApp: App {
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MaintabView()
        }
    }
}
