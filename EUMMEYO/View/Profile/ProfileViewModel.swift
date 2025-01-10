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
    @Published var tempNickname: String? //기존 닉네임 복원을 위한 임시 저장
    
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
        // 기존 닉네임을 tempNickname에 저장
        tempNickname = userInfo?.nickname
        
        // 새 닉네임을 즉시 반영
        userInfo?.nickname = nick
        userInfo?.profile = photo
        // 1. nickName update
        container.services.userService.updateUserProfile(userId: userId, nickName: nick, photo: photo)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("success")
                    self.tempNickname = nil
                    
                case .failure(let error):
                    print("닉네임 업데이트 실패: \(error)") // 오류 처리
                    // 실패 시 기존 닉네임 복원
                    self.userInfo?.nickname = self.tempNickname!
                    self.tempNickname = nil // 복원 후 tempNickname 초기화
                }
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
        
      
    }
}

