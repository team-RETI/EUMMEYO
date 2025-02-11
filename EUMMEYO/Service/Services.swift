//
//  Services.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/22/24.
//

import Foundation

enum ServiceError: Error {
    case error(Error)
    case userNotFound
}

protocol ServiceType {
    var authService: AuthenticationServiceType { get set }
    var userService: UserServiceType { get set }
    var gptAPIService: GPTAPIServiceType { get set }
}

class Services: ServiceType {
    var authService: AuthenticationServiceType
    var userService: UserServiceType
    var gptAPIService: GPTAPIServiceType
    
    // 생성자로 초기값 설정
    init() {
        self.authService = AuthenticationService()
        self.userService = UserService(dbRepository: UserDBRepository())
        self.gptAPIService = GPTAPIService(dbRepository: PromptDBRepository())
    }
}

class StubService: ServiceType {
    // 기본값을 바로 설정(테스트옹)
    var authService: AuthenticationServiceType = StubAuthenticationService()
    var userService: UserServiceType = UserService(dbRepository: UserDBRepository())
    var gptAPIService: GPTAPIServiceType = GPTAPIService(dbRepository: PromptDBRepository())
}
