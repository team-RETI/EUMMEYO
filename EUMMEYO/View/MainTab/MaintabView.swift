//
//  MaintabView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/25/24.
//

import SwiftUI

// CaseIterable는 열거형의 모든 케이스를 배열로 접근 가능
enum MainTabType: CaseIterable {
    case calendarView
    case bookmarkView
    case profileView
    
    var title: String {
        switch self {
        case .calendarView:
            return "캘린더"
        case .bookmarkView:
            return "즐겨찾기"
        case .profileView:
            return "프로필"
        }
    }
    
    func imageName(isSelected: Bool) -> String {
        switch self {
        case .calendarView:
            return isSelected ? "calendar.badge.plus" : "calendar.badge.plus"
        case .bookmarkView:
            return isSelected ? "bookmark.fill" : "bookmark"
        case .profileView:
            return isSelected ? "person.crop.circle.fill" : "person.crop.circle"
        }
    }
}

struct MaintabView: View {
    @State private var selectedTab: MainTabType = .calendarView
    // @State private var isShadowActive: Bool = false // 그림자 활성화 상태
    @StateObject var taskViewModel = TaskViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    switch selectedTab {
                    case .calendarView:
                        CalendarView()
                            .environmentObject(taskViewModel)
                    case .bookmarkView:
                        BookmarkView()
                            .environmentObject(taskViewModel)
                    case .profileView:
                        ProfileView()
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
                .frame(height: 70) // 고정 높이
                .background(Color.white) // 탭바 배경 생상
                .padding(.bottom, 15)
            }
            .edgesIgnoringSafeArea(.bottom) // 하단 여백 제거
            .background(Color.white.ignoresSafeArea()) // 전체 화면 배경 설정
            
              
            /*
            if isShadowActive {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
            }
             */
            
        }
        
        
        
        
    }
}

#Preview {
    MaintabView()
}

