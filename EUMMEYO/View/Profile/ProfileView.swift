//
//  ProfileView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI
//import PhotosUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color(Color.white) // 추후 논의
            VStack {
                // 닉네임 뷰
                NicknameView
                Spacer()
                    .frame(height: 35)
                
                HStack {
                    // 프로필 뷰
                    ImageView
                        .padding(.horizontal, 30)
                    // 카운트 뷰
                    TotalCountView
                }
                    
                // 잔디 뷰
                JandiesView
                // -------
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                //Spacer()
                
                
                // 설정버튼 뷰
                SettingBtnView
                Spacer()
                
                // 하단설명 뷰
                ExplainView
                Spacer()
                
            }
        }
        .ignoresSafeArea()
    }
}
// MARK: - nickname
var NicknameView: some View {
    HStack {
        Text("홍길동 님")
            .font(.system(size:30, weight: .bold))
            .foregroundColor(.black)
        Spacer()
    }
    .padding(.horizontal, 30)
    .padding(.top, 75)
}

// MARK: - profile image
var ImageView: some View {
    //PhotosPicker() {  }
    Image(systemName: "person.crop.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
        .foregroundColor(.black)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 5))
    
}

// MARK: - 카운트 뷰
var TotalCountView: some View {
    HStack {
        Spacer()
        
        VStack {
            Text("메모")
                .font(.system(size: 15))
                .foregroundColor(.black)
            Text("100")
                .font(.system(size:30))
                .foregroundColor(.black)
        }.frame(width: 60)
        
        Spacer()
        VStack {
            Text("함께한지")
                .font(.system(size: 15))
                .foregroundColor(.black)
            Text("10")
                .font(.system(size:30))
                .foregroundColor(.black)
        }.frame(width: 60)
        
        Spacer()
        
    }
}

// MARK: - 잔디 뷰
var JandiesView: some View {
    
    VStack {
        // 테스트용 잔디배열
        let jandies = ["잔디","잔디","잔디","잔디","잔디","잔디","잔디","잔디","잔디"]
        HStack {
            Text("나의 음메들")
                .font(.system(size:15, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 30)
        
        HStack {
            ForEach(jandies, id: \.self) { jandy in
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
            }
        }
        HStack {
            ForEach(jandies, id: \.self) { jandy in
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
            }
        }
        HStack {
            ForEach(jandies, id: \.self) { jandy in
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
            }
        }
        HStack {
            ForEach(jandies, id: \.self) { jandy in
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
            }
        }
    }
    .padding(.top, 30)
    .padding(.bottom, 20)
}

// MARK: - SettingButtonView
var SettingBtnView: some View {
    HStack {
        Button(action: {}) {
            Label( "다크모드", systemImage: "circle.lefthalf.filled")
                .padding(10)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .background(.black,
                    in: RoundedRectangle(cornerRadius: 5))
        }
        
        Button(action: {}) {
            Label( "앱 설명", systemImage: "info.circle")
                .padding(10)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .background(.black,
                    in: RoundedRectangle(cornerRadius: 5))
        }
        
        Button(action: {}) {
            Label( "공지사항", systemImage: "bell.fill")
                .padding(10)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .background(.black,
                    in: RoundedRectangle(cornerRadius: 5))
        }
        
        Button(action: {}) {
            Label( "로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                .padding(10)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .background(.red,
                    in: RoundedRectangle(cornerRadius: 5))
        }
    }.padding(.top, 30)
}

var ExplainView :some View {
    VStack {
        Text("음메요 v 1.0.0")
            .font(.system(size: 13))
            .underline()
        
        Button(action: {}) {
            Label("개인정보처리방침", systemImage: "info.circle")
                .font(.system(size: 13))
                .foregroundColor(.black)
                .underline()
        }
    }
}

#Preview {
    ProfileView()
}

