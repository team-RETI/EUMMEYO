//
//  ProfileViewModel.swift
//  EUMMEYO
//
//  Created by eunchanKim on 1/6/25.
//

import Foundation
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    
    @Published var userInfo: User?
    
    private let userId: String
    private let container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
        getUser()
        
    }
    
    func getUser(){
        container.services.userService.getUser(userId: userId)
            .sink { completion in
                switch completion {
                case .failure:
                    print("Error")
                case .finished:
                    print("Success")
                }
            } receiveValue: { user in
                self.userInfo = user
            }.store(in: &subscriptions)
    }
    
    func updateUserProfile(nick: String, photo: String){
        // TODO: 여기에 닉네임/프로필사진/테두리 색의 변화가 한가지라도 있으면 바꿀건지 묻고 yes이면 update하기
        
        // 1. nickName update
//        container.services.userService.updateUserNickname(userId: userId, nickname: nick)
        container.services.userService.updateUserProfile(userId: userId, nickName: nick, photo: photo)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("success")
                    self.userInfo?.nickname = nick
                    self.userInfo?.profile = photo
                    
                case .failure(let error):
                    print("닉네임 업데이트 실패: \(error)") // 오류 처리
                }
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
        
      
    }
}
