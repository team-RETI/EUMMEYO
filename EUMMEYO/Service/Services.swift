//
//  Services.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/22/24.
//

import Foundation

/*
 [ex]
 Repository (GPTDBRepository)가 발생시키는 GPTDBError
 Service (GPTAPIService)가 이 GPTDBError를 받아서 → ServiceError.error(GPTDBError)로 감싸서 ViewModel에 넘겨주는 구조
 
 [Repository (GPTDBRepository)]
 return Fail(error: GPTDBError.dataParsingError).eraseToAnyPublisher()

 [Service (GPTAPIService)]
 dbRepository.getPrompt()
     .mapError { ServiceError.error($0) }
     .flatMap { prompt in ... }

 [ViewModel]
 service.summarizeContent()
     .sink(receiveCompletion: { completion in
         switch completion {
         case .failure(let serviceError):
             // 여기서 serviceError는 사실 내부적으로 GPTDBError를 감싸고 있는거야
         }
     })
 */

enum ServiceError: Error {
    case error(Error) // Repository가 보낸 에러를 감싼느 에러
    case userNotFound // 사용자가 존재하지 않음
    case invalidData  // self가 nil이 되거나 데이터가 비정상
}

protocol ServiceType {
    var authService: AuthenticationServiceType { get set }
    var userService: UserServiceType { get set }
    var gptAPIService: GPTAPIServiceType { get set }
    var memoService: MemoServiceType { get set }
}

class Services: ServiceType {

    var authService: AuthenticationServiceType
    var userService: UserServiceType
    var gptAPIService: GPTAPIServiceType
    var memoService: MemoServiceType
    
    // 생성자로 초기값 설정
    init() {
        self.authService = AuthenticationService()
        self.userService = UserService(dbRepository: UserDBRepository())
        self.gptAPIService = GPTAPIService(dbRepository: GPTDBRepository())
        self.memoService = MemoService(dbRepository: MemoDBRepository())
    }
}

class StubService: ServiceType {
    // 기본값을 바로 설정(테스트옹)
    var authService: AuthenticationServiceType = StubAuthenticationService()
    var userService: UserServiceType = UserService(dbRepository: UserDBRepository())
    var gptAPIService: GPTAPIServiceType = GPTAPIService(dbRepository: GPTDBRepository())
    var memoService:  MemoServiceType = MemoService(dbRepository: MemoDBRepository())
}
