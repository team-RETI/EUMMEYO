//
//  LoginView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/23/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("음메요 로고")
                .font(.system(size: 50, weight: .bold))
            
            Spacer()
            
            // MARK: - 애플 로그인 버튼은 직접 커스텀할 수 없기 때문에 실제 버튼 위에 커스텀 버튼을 올려준다.
            ZStack {
                // MARK: - 실제 Apple 로그인 버튼
                SignInWithAppleButton(.continue, onRequest: { request in
                    print("Apple 로그인 요청")
                }, onCompletion: { result in
                    print("Apple 로그인 완료")
                })
                .frame(maxWidth: .infinity, maxHeight: 60)
                .accessibilityIdentifier("appleLoginButton") // 식별자 추가
                .opacity(0.1) // 버튼 숨김 대신 투명도 적용 (배경처럼 동작)
                
                // MARK: - 애플 커스텀 Ui
                Button {
                    triggerAppleLoginButtonTap()
                } label: {
                    HStack {
                        Image(systemName: "applelogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                        
                        
                        Spacer()
                        
                        Text("Apple로 계속하기")
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    .padding(.horizontal, 45)
                }.buttonStyle(SocialButtonStyle(buttonType: "Apple"))
            }
            
            // MARK: - Google 버튼
            Button {
                print("Google 로그인 요청")
            } label: {
                HStack {
                    Image("Google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        
                    Spacer()
                    
                    Text("Google로 계속하기")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 45)
            }.buttonStyle(SocialButtonStyle(buttonType: "Google"))
            
            Spacer()
                .frame(height:130)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 커스텀 애플 버튼을 누르면 실제 애플 로그인 버튼을 누르도록 트리거 하는 함수
    // Apple 로그인 버튼을 찾고 동작 트리거
    func triggerAppleLoginButtonTap() {
        guard let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }),
              let appleButton = findAppleSignInButton(in: keyWindow) else {
            print("Apple 로그인 버튼을 찾을 수 없습니다.")
            return
        }

        // 버튼 액션 강제 실행
        appleButton.sendActions(for: .touchUpInside)
    }
    
    func findAppleSignInButton(in view: UIView) -> ASAuthorizationAppleIDButton? {
        for subview in view.subviews {
            if let appleButton = subview as? ASAuthorizationAppleIDButton {
                return appleButton
            }
            if let found = findAppleSignInButton(in: subview) {
                return found
            }
        }
        return nil
    }
}

#Preview {
    LoginView()
}

// 로그인 버튼 스타일
struct SocialButtonStyle: ButtonStyle {
    let buttonType: String
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(
                buttonType == "Google" ? Color.black :
                    buttonType == "Kakao" ? Color.black.opacity(0.85) :
                Color.white // 애플 버튼 레이블 색상
            )
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        buttonType == "Google" ? Color.white :
                        buttonType == "Kakao" ? Color("#FEE500") :
                        Color.black // 애플 버튼 배경색
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        buttonType == "Google" ? Color.black :
                        buttonType == "Kakao" ? Color("#FEE500") :
                        Color.clear, lineWidth: 0.8 // 테두리 색상
                    )
            )
            .opacity(configuration.isPressed ? 0.5 : 1)
            //.padding(.horizontal, 15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

