//
//  AuthenticationViewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/24/24.
//

import Foundation
import Combine
import AuthenticationServices


enum AuthenticationState {
    case unauthenticated    // 미인증
    case authenticated      // 인증
    case firstTimeLogin     // 최초 로그인
}

final class AuthenticationViewModel: ObservableObject {
    enum Action {
        case checkAuthenticationState
        case googleLogin
        case appleLogin(ASAuthorizationRequest)
        case appleLoginCompletion(Result<ASAuthorization, Error>)
        case checkNickname(User)
        case checkNicknameDuplicate(String, (Bool) -> Void)
        case updateUserNickname(String)
        case logout
    }
    
    @Published var authenticatedState = AuthenticationState.unauthenticated
    @Published var isLoading = false
    
    var userId: String?
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    private var currentNonce: String?
    
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
                
                // Firebase에서 사용자 정보를 가져와 닉네임 확인
                container.services.userService.getUser(userId: userId)
                    .sink { [weak self] completion in
                        if case .failure = completion {
                            self?.authenticatedState = .unauthenticated
                        }
                    } receiveValue: { [weak self] user in
                        // 닉네임 유무 확인
                        self?.send(action: .checkNickname(user))
                    }
                    .store(in: &subscriptions)
            }

        // 구글 로그인
        case .googleLogin:
            isLoading = true
            // MARK: - 구글 인증 성공시 flatmap 진행
            container.services.authService.signInWithGoogle()
                .flatMap { user in
                    // MARK: - 사용자가 존재하는지 getUser로 확인 후, 없으면 최초 로그인이므로 addUser호출 로직
                    self.container.services.userService.getUser(userId: user.id)
                        .catch { error -> AnyPublisher<User, ServiceError> in
                            return self.container.services.userService.addUser(user)
                        }
                }
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.isLoading = false
                        print("구글 실패")
                    }
                } receiveValue: { [weak self] user in
                    self?.isLoading = false
                    self?.userId = user.id
                    
                    // MARK: - 닉네임 유무를 확인하는 구간
                    self?.send(action: .checkNickname(user))
                    
                }.store(in: &subscriptions)
            
        // 애플 로그인
        case let .appleLogin(request):
            let nonce = container.services.authService.handleSignInWithAppleRequest(request as! ASAuthorizationAppleIDRequest)
            currentNonce = nonce
            
        case let .appleLoginCompletion(result):
            if case let .success(authorization) = result {
                guard let nonce = self.currentNonce else {
                    print("Error: Missing nonce")
                    return
                }
                
                container.services.authService.handleSignInWithAppleCompletion(authorization, nonce: nonce)
                    .flatMap { user in
                        self.container.services.userService.getUser(userId: user.id)
                            .catch { error -> AnyPublisher<User, ServiceError> in
                                return self.container.services.userService.addUser(user)
                            }
                    }
                    .sink { [weak self] completion in
                        if case let .failure(error) = completion {
                            self?.isLoading = false
                            // 구체적인 에러 정보 출력
                            print("애플 로그인 실패: \(error.localizedDescription)")
                            

                        }
                    } receiveValue: { [weak self] user in
                        self?.isLoading = false
                        self?.userId = user.id
                        
                        // MARK: - 닉네임 유무를 확인하는 구간
                        self?.send(action: .checkNickname(user))
                        
                    }.store(in: &subscriptions)
            }
            
        case .checkNickname(let user):
            if user.nickname.trimmingCharacters(in: .whitespaces).isEmpty {
                self.authenticatedState = .firstTimeLogin
            } else {
                self.authenticatedState = .authenticated
            }
            
        case .updateUserNickname(let nickname):
            guard let userId = userId else { return } // 사용자 ID가 없으면 리턴
            
            // container.services.userService를 통해 닉네임 업데이트 호출
            container.services.userService.updateUserNickname(userId: userId, nickname: nickname)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.authenticatedState = .authenticated // 닉네임 설정 후 인증 상태 변경
                    case .failure(let error):
                        print("닉네임 업데이트 실패: \(error)") // 오류 처리
                    }
                }, receiveValue: { _ in })
                .store(in: &subscriptions)
            
        case .logout:
            container.services.authService.logout()
                .sink { completion in
                      
                } receiveValue: { [weak self] _ in
                    self?.authenticatedState = .unauthenticated
                    self?.userId = nil
                }.store(in: &subscriptions)
        
        case .checkNicknameDuplicate(let nickname, let completion):
            container.services.userService.checkNicknameDuplicate(nickname)
                .sink { result in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            print("닉네임 중복 확인 오류: \(error.localizedDescription)")
                            completion(false) // 오류 발생 시 false 반환
                        }
                    case .finished:
                        break
                    }
                } receiveValue: { isDuplicate in
                    DispatchQueue.main.async {
                        if isDuplicate {
                            completion(true) // 중복된 경우 클로저에 true 전달
                        } else {
                            completion(false) // 중복되지 않은 경우 클로저에 false 전달
                        }
                    }
                }
                .store(in: &subscriptions)
        }
    }
}
