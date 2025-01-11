//
//  AuthenticationView.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/24/24.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            switch authViewModel.authenticatedState {
            case .unauthenticated:
                LoginView()
                    .environmentObject(authViewModel)
            case .authenticated:
                MaintabView()
                    .environmentObject(authViewModel)
            case .firstTimeLogin:
                NicknameSettingView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.send(action: .checkAuthenticationState)
        }
    }
}

#Preview {
    AuthenticationView(authViewModel: AuthenticationViewModel(container: DIContainer(services: StubService())))
}

//import SwiftUI
//
//struct AuthenticationView: View {
//    @StateObject var authViewModel: AuthenticationViewModel
//
//    var body: some View {
//        ZStack {
//            // 기본 뷰
//            switch authViewModel.authenticatedState {
//            case .unauthenticated:
//                LoginView()
//                    .environmentObject(authViewModel)
//            case .authenticated:
//                MaintabView()
//                    .environmentObject(authViewModel)
//            default:
//                EmptyView() // 기본 상태 처리
//            }
//
//            // 닉네임 설정 뷰 (애니메이션 포함)
//            if authViewModel.authenticatedState == .firstTimeLogin {
//                NicknameSettingView()
//                    .environmentObject(authViewModel)
//                    .transition(.move(edge: .trailing)) // 애니메이션 적용
//                    .zIndex(1) // 위에 표시
//            }
//        }
//        .onAppear {
//            authViewModel.send(action: .checkAuthenticationState)
//        }
//    }
//}
