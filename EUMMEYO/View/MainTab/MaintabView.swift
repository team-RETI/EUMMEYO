//
//  MaintabView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/25/24.
//

import SwiftUI

// CaseIterable는 열거형의 모든 케이스를 배열로 접근 가능
enum MainTabType: CaseIterable {
    case scheduleAutoRegisterView
    case autoMemoView
    case scheduleMemoView
    case voiceMemoView
    case profileView
    
    var title: String {
        switch self {
        case .scheduleAutoRegisterView:
            return "일정 등록"
        case .autoMemoView:
            return "자동 메모"
        case .scheduleMemoView:
            return "일정 메모"
        case .voiceMemoView:
            return "음성 메모"
        case .profileView:
            return "프로필"
        }
    }
    
    func imageName(isSelected: Bool) -> String {
        switch self {
        case .scheduleAutoRegisterView:
            return isSelected ? "calendar.badge.plus" : "calendar.badge.plus"
        case .autoMemoView:
            return isSelected ? "pencil.circle.fill" : "pencil.circle"
        case .scheduleMemoView:
            return isSelected ? "note.text.badge.plus" : "note.text.badge.plus"
        case .voiceMemoView:
            return isSelected ? "mic.fill" : "mic"
        case .profileView:
            return isSelected ? "person.crop.circle.fill" : "person.crop.circle"
        }
    }
}

struct MaintabView: View {
    @State private var selectedTab: MainTabType = .scheduleAutoRegisterView
    var body: some View {
        VStack {
            ZStack {
                switch selectedTab {
                case .scheduleAutoRegisterView:
                    TestView()
                case .autoMemoView:
                    TestView()
                case .scheduleMemoView:
                    TestView()
                case .voiceMemoView:
                    TestView()
                case .profileView:
                    TestView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // MARK: - 커스텀 탭 바
            HStack(spacing: 0) {
                ForEach(MainTabType.allCases, id: \.self) { tab in
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: tab.imageName(isSelected: selectedTab == tab))
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                        
                        Text(tab.title)
                            .font(.caption)
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.white) // 탭바 요소 배경 색상
                    .onTapGesture {
                        selectedTab = tab
                    }
                    Spacer()
                }
            }
            .frame(height: 90) // 고정 높이
            .background(Color.white) // 탭바 배경 생상
            .padding(.bottom, 15)
        }
        .edgesIgnoringSafeArea(.bottom) // 하단 여백 제거
        .background(Color.white.ignoresSafeArea()) // 전체 화면 배경 설정
        
        
    }
}

#Preview {
    MaintabView()
}

struct TestView: View {
    var body: some View {
        VStack {
            Text("테스트 뷰")
        }
    }
}
