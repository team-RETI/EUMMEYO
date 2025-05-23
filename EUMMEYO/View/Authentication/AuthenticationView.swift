//
//  AuthenticationView.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/24/24.
//

import SwiftUI

struct AuthenticationView: View {

    @EnvironmentObject var container: DIContainer
    @StateObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            switch authViewModel.authenticatedState {
            case .unauthenticated:
                LoginView()
                    .environmentObject(authViewModel)

            case .authenticated:
                MaintabView(memoStore: MemoStore(container: container, userId: authViewModel.userId ?? "unknown"))
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


struct AuthenticationView_Previews: PreviewProvider {
    static let container: DIContainer = .stub
    
    static var previews: some View {
        AuthenticationView(authViewModel: .init(container: Self.container))
            .environmentObject(Self.container)
    }
}

