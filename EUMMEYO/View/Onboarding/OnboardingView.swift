//
//  OnboardingView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/25/24.
//

import SwiftUI

// MARK: - Model
struct OnboardingContent: Hashable {
    // 객체가 고유한 해시 값을 가지기 위해 사용, ForEach와 같은 뷰 빌더에서 고유성을 보장하기 위해(고유ID를 사용하기 위해) 사용
    var imageFileName: String
    var title: String
    var subTitle: String
}

// MARK: - ViewModel
final class OnboardingViewModel: ObservableObject {
    @Published var onboardingcontents: [OnboardingContent]
    
    init(onboardingcontents: [OnboardingContent] = [
        .init(
            imageFileName: "onboarding_1",
            title: "말하면 등록 끝!",
            subTitle: "음성으로 일정 등록하고 알림도 받아보세요."),
        
        .init(imageFileName: "onboarding_2",
              title: "자동으로 뚝딱 정리!",
              subTitle: "음성을 분석해 일상, 건강, 여행 등 깔끔하게 정리해요."),

        .init(imageFileName: "onboarding_3",
              title: "내 기록이 한눈에!",
              subTitle: "누구랑 약속을 잘 지켰는지 통계로 확인해보세요."),

        .init(imageFileName: "onboarding_4",
              title: "바로 녹음하세요!",
              subTitle: "위젯 버튼 하나로 급한 메모도 빠르게 기록 가능!")
    ]
    ) {
        self.onboardingcontents = onboardingcontents
    }
}

// MARK: - View
struct OnboardingView: View {
    @ObservedObject private var onboardingViewModel: OnboardingViewModel
    
    init(onboardingViewModel: OnboardingViewModel) {
        self.onboardingViewModel = onboardingViewModel
    }
    
    var body: some View {
        VStack {
            OnboardingCellListView(onboardingViewModel: onboardingViewModel)
            
            Spacer()
                .frame(height: 50)
            
            StartBtnView()
            
        }
    }
}

// MARK: - 온보딩 셀 리스트 뷰
private struct OnboardingCellListView: View {
    @ObservedObject private var onboardingViewModel: OnboardingViewModel
    @State private var selectedIndex: Int
    
    fileprivate init(onboardingViewModel: OnboardingViewModel, selectedIndex: Int = 0) {
        self.onboardingViewModel = onboardingViewModel
        self.selectedIndex = selectedIndex
    }
    
    fileprivate var body: some View {
        VStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(onboardingViewModel.onboardingcontents.enumerated()), id: \.element) { index, onboardingContent in
                    OnboardingCellView(onboardingContent: onboardingContent)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.5)
        }
    }
}

// MARK: - 온보딩 셀 뷰
private struct OnboardingCellView: View {
    private var onboardingContent: OnboardingContent
    
    fileprivate init(onboardingContent: OnboardingContent) {
        self.onboardingContent = onboardingContent
    }
    
    fileprivate var body: some View {

        VStack {
            Image(onboardingContent.imageFileName)
                .resizable()    // 이미지 크기 변경 가능하도록 설정
                .scaledToFit()  // 원본 비율 유지하며 크기를 뷰에 맞춤
                //.frame(width: 200, height: 200) // 크기를 제한
                .cornerRadius(10)
            
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                        .frame(height: 46)
                    
                    Text(onboardingContent.title)
                        .font(.system(size: 16, weight: .bold))
                    
                    Spacer()
                        .frame(height: 5)
                    
                    Text(onboardingContent.subTitle)
                        .font(.system(size: 16))
                }
                Spacer()
            }
            .background(.white)
            
        }
        .padding(.top, 20)
        .shadow(radius: 10)
    }
}


private struct StartBtnView: View {
    fileprivate var body: some View {
        Button {
            
        } label: {
            HStack {
                Text("시작하기")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
            }
        }
        .padding(.bottom, 150)
    }
}

//#Preview {
//    StartBtnView()
//}

#Preview {
    OnboardingView(onboardingViewModel: .init())
}

