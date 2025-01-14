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
    
    // 생년월일 날짜 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter
    }
    
    // 전송용 생년월일 날짜 포맷터
    private var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST 설정
        return formatter
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
            
            Text("생년월일")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                isDatePickerActive.toggle()
            } label: {
                Text("\(dateFormatter.string(from: birthdate))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.mainBlack)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1.5)
                            .foregroundColor(.black)
                    )
            }
            
            Spacer()
                .frame(height: 10)
            
            Text("성별")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                GenderButton(gender: .male, isSelected: $selectedGender)
                GenderButton(gender: .female, isSelected: $selectedGender)
                GenderButton(gender: .other, isSelected: $selectedGender)
            }
            
            
            Spacer()
            
            Button {
                if isNicknameValid {
                    authViewModel.send(action: .checkNicknameDuplicate(nickname) { isDuplicate in
                        
                        if isDuplicate {
                            nicknameMessage = "닉네임이 중복되었습니다"
                        } else {
                            // 업데이트 성공
                            nicknameMessage = ""
                            //authViewModel.send(action: .updateUserNickname(nickname))
                            
                            let birthdayString = isoDateFormatter.string(from: birthdate)
                            print("디버깅: \(birthdayString)")
                            let genderString = selectedGender.rawValue
                            authViewModel.send(action: .updateUserInfo(nickname, birthdayString, genderString))
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
//            withAnimation(.easeOut(duration: 0.4)) { // 0.3초 동안 easeOut 애니메이션
                slideOffset = 0 // 오프셋을 0으로 만들어 화면 중앙으로 이동
//            }
        }
        .sheet(isPresented: $isDatePickerActive) {
            BirthdayPickerView(birthdate: $birthdate)
                .presentationDetents([.fraction(0.5)])
        }
    }
}

#Preview {
    NicknameSettingView()
}


// MARK: - 생년월일 선택
private struct BirthdayPickerView: View {
    @Binding var birthdate: Date
    @Environment(\.dismiss) private var dismiss // sheet 닫기
    
    fileprivate var body: some View {
        VStack {
             Text("생년월일 선택")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 50)
                .font(.system(size: 20, weight: .bold))
                
            DatePicker(
                "생년얼일",
                selection: $birthdate,
                in: ...Date(), // 현재 날짜까지 선택 가능
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.black, lineWidth: 2)
            )
            .environment(\.locale, Locale(identifier: "ko_KR"))
            
            Spacer()
                .frame(height: 30)
            
            Button {
                dismiss()
            } label: {
                Text("완료")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(Color.mainBlack)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 40)
            
        }
    }
}

// MARK: - 성별 버튼
private struct GenderButton: View {
    
    // 성별
    var gender: Gender
    
    // 선택유무
    @Binding var isSelected: Gender
    
    fileprivate var  body: some View {
        Button {
            isSelected = gender
        } label: {
            Text(gender.rawValue)
                .foregroundColor(isSelected == gender ? Color.white : Color.black)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 2)
                }
                .background(isSelected == gender ? Color.mainBlack : Color.white) // 선택 여부에 따라 배경색 변경
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
