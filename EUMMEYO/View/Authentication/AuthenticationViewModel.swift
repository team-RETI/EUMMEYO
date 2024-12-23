//
//  AuthenticationViewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/24/24.
//

import Foundation
import Combine


enum AuthenticationState {
    case unauthenticated
    case authenticated
}

final class AuthenticationViewModel: ObservableObject {
    enum Action {
        case checkAuthenticationState
        case googleLogin
        case logout
    }
    
    @Published var authenticatedState = AuthenticationState.unauthenticated
    @Published var isLoading = false
    var userId: String?
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
            
        // 로그인 상태 확인
        case .checkAuthenticationState:
            if let userId = container.services.authService.checkAuthenticationState() {
                self.userId = userId
                self.authenticatedState = .authenticated
            }
            
        // 구글 로그인
        case .googleLogin:
            isLoading = true
            container.services.authService.signInWithGoogle()
                .flatMap { user in
                    
                    self.container.services.userService.addUser(user)
                }
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.isLoading = false
                        print("실패")
                    }
                } receiveValue: { [weak self] user in
                    self?.isLoading = false
                    self?.userId = user.id
                    self?.authenticatedState = .authenticated
                    print("성공")
                }.store(in: &subscriptions)
            
        case .logout:
            container.services.authService.logout()
                .sink { completion in
                      
                } receiveValue: { [weak self] _ in
                    self?.authenticatedState = .unauthenticated
                    self?.userId = nil
                }.store(in: &subscriptions)
        }
    }
}
