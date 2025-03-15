//
//  OnboardingView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/25/24.
//

import SwiftUI

// MARK: - Model
struct OnboardingContent: Hashable {
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
            title: "메모 작성",
            subTitle: "아이디어와 일정을 빠르게 기록해보세요."),
        .init(
            imageFileName: "onboarding_2",
            title: "즐겨찾기",
            subTitle: "중요한 메모를 즐겨찾기에 추가해 손쉽게 찾아보세요."),
        .init(
            imageFileName: "onboarding_3",
            title: "검색 기능",
            subTitle: "작성한 메모를 빠르고 정확하게 검색해보세요."),
        .init(
            imageFileName: "onboarding_4",
            title: "프로필",
            subTitle: "나의 설정과 기록을 한눈에 확인하세요.")
    ]) {
        self.onboardingcontents = onboardingcontents
    }
}

// MARK: - View
struct OnboardingView: View {
    @ObservedObject private var onboardingViewModel: OnboardingViewModel
    @State private var selectedIndex: Int = 0
    
    init(onboardingViewModel: OnboardingViewModel) {
        self.onboardingViewModel = onboardingViewModel
    }
    
    var body: some View {
        VStack {
            OnboardingCellListView(
                onboardingViewModel: onboardingViewModel,
                selectedIndex: $selectedIndex
            )
            
            Spacer()
                .frame(height: 50)
            
            StartBtnView(
                selectedIndex: $selectedIndex,
                lastIndex: onboardingViewModel.onboardingcontents.count - 1
            )
        }
    }
}

// MARK: - 온보딩 셀 리스트 뷰
private struct OnboardingCellListView: View {
    @ObservedObject private var onboardingViewModel: OnboardingViewModel
    @Binding var selectedIndex: Int
    
    init(onboardingViewModel: OnboardingViewModel, selectedIndex: Binding<Int>) {
        self.onboardingViewModel = onboardingViewModel
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(onboardingViewModel.onboardingcontents.enumerated()), id: \.element) { index, onboardingContent in
                OnboardingCellView(onboardingContent: onboardingContent)
                    .tag(index) // 각 셀에 태그 부여
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.5)
    }
}

// MARK: - 온보딩 셀 뷰
private struct OnboardingCellView: View {
    private var onboardingContent: OnboardingContent
    
    init(onboardingContent: OnboardingContent) {
        self.onboardingContent = onboardingContent
    }
    
    var body: some View {
        VStack {
            Image(onboardingContent.imageFileName)
                .resizable()
                .scaledToFit()
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

// MARK: - 버튼 뷰
private struct StartBtnView: View {
    @AppStorage("_isFirstLaunching") private var isFirstLaunching: Bool = true
    @Binding var selectedIndex: Int
    var lastIndex: Int
    
    var body: some View {
        Button {
            if selectedIndex < lastIndex {
                withAnimation(.easeInOut) {
                    selectedIndex += 1
                }
            } else {
                isFirstLaunching = false
            }
        } label: {
            HStack {
                Text(selectedIndex < lastIndex ? "다음" : "시작하기")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
            }
        }
        .padding(.bottom, 50)
    }
}

//#Preview {
#Preview {
    OnboardingView(onboardingViewModel: .init())
}
