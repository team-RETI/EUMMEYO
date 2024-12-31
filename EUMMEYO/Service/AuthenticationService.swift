//
//  AuthenticationService.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/22/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

// 에러타입
enum AuthenticationError: Error {
    case clientIDError      // Firebase CliendID 가져오지 못했을 때 발생
    case tokenError         // Google로그인 중 토큰을 가져오지 못했을 때 발생
    case invalidated        // 인증이 무효되었을 때 발생
}

protocol AuthenticationServiceType {
    // 구글 로그인
    // 반환타입으로 Combine의 AnyPublisherfmf 사용해 비동기 작업의 결과를 처리한다
    func signInWithGoogle() -> AnyPublisher<User, ServiceError>
    
    // 로그인 확인
    func checkAuthenticationState() -> String?
    
    // 로그아웃
    func logout() -> AnyPublisher<Void, ServiceError>
}

// 인증 서비스
final class AuthenticationService: AuthenticationServiceType {
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.signInWithGoogle() { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func checkAuthenticationState() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return nil
        }
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(.error(error)))
            }
        }.eraseToAnyPublisher()
    }
}

final class StubAuthenticationService: AuthenticationServiceType {
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func checkAuthenticationState() -> String? {
        return nil
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}

extension AuthenticationService {
    
    // 실제 구글 로그인 비동기 작업을 수행하는 함수. 결과값을 SignInWidhGoogle()에서 combine의 Future로 변환하여 사용 가능.
    private func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        
        // Firebase에서 제공하는 clientID를 가져온다. 실패시 clientIDError를 반환한다.
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthenticationError.clientIDError)) // 실패시
            return
        }
        
        // GIDConfiguration 객체를 생성하여 Google Sign-In 구성을 초기화한다
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Google Sign-in 창을 띄울 rootViewController을 가져온다
        // 현재 실행 중인 UIApplication에서 UIWindow를 탐색하여 추출한다
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // 로그인 진행
        // 성공시 result 객체를 반환
        // result.user에서 idToken, accessToken을 가져온다
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                // 유저정보, 토큰정보가 없다면
                completion(.failure(AuthenticationError.tokenError))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Firebase인증에 필요한 AuthCredential를 생성하여 authenticateUserWithFirebase로 전달한다
            self?.authenticateUserWithFirebase(credential: credential, completion: completion)
        }
    }
    
    // MARK: - 파이어베이스 인증 진행 함수
    private func authenticateUserWithFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void ) {
        // Firebase 서버에 인증 요청을 보낸다
        Auth.auth().signIn(with: credential) { result, error in
            // 인증 실패시 에러를 completion으로 반환한다.
            if let error {
                completion(.failure(error))
                return
            }
            
            // 인증 결과가 없는 경우 invalidated 에러를 반환한다
            guard let result else {
                completion(.failure(AuthenticationError.invalidated))
                return
            }
            
            // 기존 사용자: 기존 uid를 반환
            // 새 사용자: 새로운 uid를 반환
            let firebaseUser = result.user
            
            // ISO8601DateFormatter를 사용해 한국 시간대에 맞게 날짜 생성
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST설정
            let registerDate = formatter.date(from: formatter.string(from: Date()))
            
            // User객체 생성
            let user = User(
                id: firebaseUser.uid,
                // nickname: firebaseUser.displayName ?? "Unknown",
                loginPlatform: .google,
                registerDate: registerDate ?? Date())
            
            completion(.success(user))
        }
    }
}
