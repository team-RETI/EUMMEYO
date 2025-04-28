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
            return "검색"
        case .profileView:
            return "프로필"
        }
    }
    
    func imageName(isSelected: Bool) -> String {
        switch self {
        case .calendarView:
            return isSelected ? "calendar.badge.plus" : "calendar.badge.plus"
        case .bookmarkView:
            return isSelected ? "magnifyingglass" : "magnifyingglass"
        case .profileView:
            return isSelected ? "person.crop.circle.fill" : "person.crop.circle"
        }
    }
}

struct MaintabView: View {
    @State private var selectedTab: MainTabType = .calendarView
    @EnvironmentObject var authViewModel : AuthenticationViewModel
    @EnvironmentObject var container: DIContainer
    @StateObject var calendarViewModel: CalendarViewModel
    @StateObject var audioRecorderManager: AudioRecorderManager

    // evan : 1. "TabView" 키워드를 사용하지 않으면 탭을 누를 시 계속 초기화 됨 2. tab뷰를 불러올 때 초기화하지 않고 environmentObject로만 불렀을때는 탭을 누를 시 계속 초기화 됨
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .calendarView:
                        CalendarView()
                            .environmentObject(calendarViewModel)
                           
                    case .bookmarkView:
                        BookmarkView()
                            .environmentObject(calendarViewModel)
                        
                    case .profileView:
                        ProfileView()
                            .environmentObject(calendarViewModel)
                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.imageName(isSelected: selectedTab == tab))
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .accentColor(.mainBlack)
    }
}
    
