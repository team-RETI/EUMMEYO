//
//  BookmarkView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var container: DIContainer
    @StateObject var viewModel: BookmarkViewModel
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        withAnimation(.spring(duration: 0.5)) {
                            viewModel.toggleButtonTapped.toggle()
                        }
                        // 진동 발생
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        Image(systemName: viewModel.toggleButtonTapped ? "star.fill" : "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20.scaled, height: 20.scaled)
                            .foregroundColor(.mainBlack)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30.scaled, height: 30.scaled)
                                    .foregroundColor(.mainBlack)
                            }
                    }
                }
                .hTrailing()
                .padding(.trailing, 32)
                .padding(.bottom)
                
                // 검색창
                if !viewModel.toggleButtonTapped {
                    TextField("검색어를 입력하세요", text: $viewModel.searchText)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.scaled)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.mainBlack)
                                .frame(height: 50.scaled)
                        )
                        .padding(.horizontal)
                }
                
            }
   
            // 리스트 데이터를 먼저 변수에 저장하여 중복 방지
            let memos = viewModel.toggleButtonTapped ? viewModel.bookmarkedMemos : viewModel.memoStore.memoList

            if memos.isEmpty {
                Text(viewModel.toggleButtonTapped ? "즐겨찾기된 항목이 없습니다." : "메모가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 15.scaled) {
                        ForEach(memos) { memo in
                            NavigationLink {
                                MemoDetailView(
                                    viewModel: MemoDetailViewModel(
                                        memoStore: viewModel.memoStore,
                                        container: container,
                                        audioPlayer: AudioPlayerRepository()
                                    ),
                                    memo: memo
                                )
                            } label: {
                                MemoCardView(
                                    viewModel: MemoCardViewModel(
                                        memoStore: viewModel.memoStore,
                                        container: container
                                    ),
                                    memo: memo
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            Spacer()
        }
    }
}
