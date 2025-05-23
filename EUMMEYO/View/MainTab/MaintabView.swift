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
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var bookmarkViewModel: BookmarkViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @StateObject var memoStore: MemoStore

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .calendarView:
                        CalendarView(viewModel: .init(container: container, userId: authViewModel.userId ?? "unknown", memoStore: memoStore, userStore: authViewModel))
                           
                    case .bookmarkView:
                        BookmarkView(viewModel: .init(container: container, userId: authViewModel.userId ?? "unknown", memoStore: memoStore))
                        
                    case .profileView:
                        ProfileView(viewModel: .init(container: container, userId: authViewModel.userId ?? "unknown", memoStore: memoStore, userStore: authViewModel))

                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.imageName(isSelected: selectedTab == tab))
                }
            }
        }
        .onAppear {
            if memoStore.userId == "placeholder", let userId = authViewModel.userId {
                memoStore.setUserId(userId)
                memoStore.observeMemos()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .accentColor(.mainBlack)
    }
}
    
