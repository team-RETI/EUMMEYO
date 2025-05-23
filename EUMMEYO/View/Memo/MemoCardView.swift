//
//  MemoCardView.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/20/25.
//

import SwiftUI

struct MemoCardView: View {
    @StateObject var viewModel: MemoCardViewModel
    @State var offsetX: CGFloat = 0 // 드래그 거리
    @State var showDelete: Bool = false // 삭제 버튼 표시 여부
    var memo: Memo
    
    var body: some View {
        ZStack{  // 삭제 버튼용
            HStack {
                Button {
                    viewModel.memoStore.deleteTarget = memo
                    viewModel.memoStore.showDeleteMemoAlarm.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(
                            Color.white
                                .opacity(showDelete ? 1 : 0)
                        )
                        .padding()
                        .background(
                            Color.red
                                .opacity(showDelete ? 1 : 0)
                        )
                        .cornerRadius(10.scaled)
                }
                .padding(.trailing, 10)
            }
            .hTrailing()
            
            HStack(alignment: .top, spacing: 30.scaled) {
                VStack(spacing: 10.scaled) {
                    Circle()
                        .fill(.mainBlack)
                        .frame(width: 7.scaled, height: 7.scaled)
                        .background(
                            Circle()
                                .stroke(.mainBlack, lineWidth: 1)
                                .padding(-3)
                        )
                    Rectangle()
                        .fill(.mainBlack)
                        .frame(width: 1.0.scaled)
                }
                
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .center) {
                        Image(systemName: memo.isVoice ? "mic" : "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 12.scaled, height: 12.scaled)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(.black)
                                    .frame(width: 30.scaled, height: 30.scaled)
                            )
                    }
                    VStack(alignment: .leading, spacing: 12.scaled) {
                        Text(memo.title)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Text(memo.gptContent ?? "요약 없음")
                            .font(.system(size: 10.scaled))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .hLeading()
                    
                    VStack {
                        Text(memo.date.formatted(date: .numeric, time: .omitted))
                            .font(.system(size: 15.scaled))
                        Button {
                            viewModel.isBookmark = memo.isBookmarked
                            viewModel.isBookmark.toggle()
                            viewModel.toggleBookmark(memoId: memo.id, isBookmark: viewModel.isBookmark)
                        } label: {
                            Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                                .foregroundColor(memo.isBookmarked ? .mainPink : .mainGray)
                                .padding(1)
                        }
                    }
                }
                .padding()
                .foregroundColor(memo.date.isCurrentHour && viewModel.isToday(date: memo.date) ? .mainWhite : .mainBlack)
                .background(memo.date.isCurrentHour && viewModel.isToday(date: memo.date) ? .mainBlack : .mainWhite)
                .cornerRadius(25.scaled)
                .overlay {
                    RoundedRectangle(cornerRadius: 25.scaled)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.mainBlack)
                }
            }
            .offset(x: offsetX.isFinite ? offsetX : 0) // NaN 방지
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        offsetX = gesture.translation.width.clamped(to: -100...10) // 최대 이동 거리 제한
                    }
                    .onEnded { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                if offsetX <= -75 {
                                    offsetX = -70
                                    showDelete = true
                                } else {
                                    offsetX = 0
                                    showDelete = false
                                }
                            }
                        }
                    }
            )
        }
    }
}
