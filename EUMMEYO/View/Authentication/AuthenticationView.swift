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
