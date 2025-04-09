//
//  NicknameSettingView.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/30/24.
//

import SwiftUI

struct NicknameSettingView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    @State private var nickname: String = ""                             // 닉네임입력
    @State private var nicknameMessage: String? = nil                    // 닉네임 오류 메시지
    @State private var slideOffset: CGFloat = UIScreen.main.bounds.width // 화면 너비만큼 오프셋 시작
    @State private var birthdate: Date = Date()                          // 기본값: 2000년 1월 1일
    @State private var isDatePickerActive: Bool = false                  // 생일입력
    @State private var selectedGender: Gender = .male                    // 성별입력

    // 닉네임이 유효한지 검사하는 프로퍼티
    private var isNicknameValid: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("음메요")
                .font(.system(size: 30, weight: .bold))
                .padding(.bottom, 10)
                
            Text("회원가입에 필요한 정보를 입력해주세요")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(height: 10)
            
            Text("닉네임")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("2자 이상 20자 이하로 입력해주세요", text: $nickname)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1.5)
                        .foregroundColor(Color.mainBlack)
                )
                
            if let message = nicknameMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
                .frame(height: 10)
        
            Spacer()
            
            Button {

                if isNicknameValid {
                    authViewModel.send(action: .checkNicknameDuplicate(nickname) { isDuplicate in
                        
                        if isDuplicate {
                            nicknameMessage = "닉네임이 중복되었습니다"
                        } else {
                            // 업데이트 성공
                            nicknameMessage = ""
                        
                            authViewModel.send(action: .updateUserInfo(nickname, "", ""))
                        }
                    })
                }
                
            } label: {
                Text("완료")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(!nickname.isEmpty ? Color.mainBlack : Color.gray)
                    .cornerRadius(20)
            }
            .disabled(nickname.isEmpty)
            
            
        }.padding(.horizontal, 25)
        .offset(x: slideOffset) // x축 오프셋 적용
        .onAppear {
            slideOffset = 0 // 오프셋을 0으로 만들어 화면 중앙으로 이동
        }
    }
}

#Preview {
    NicknameSettingView()
}
