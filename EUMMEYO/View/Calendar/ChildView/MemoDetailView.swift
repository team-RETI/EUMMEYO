//
//  MemoDetailView.swift
//  EUMMEYO
//
//  Created by eunchanKim on 4/10/25.
//

import SwiftUI
import AVFoundation

struct MemoDetailView: View {
    var memo: Memo
    @EnvironmentObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isVoiceView = false // 어떤 뷰를 보여줄지 상태 저장
    @State private var showUpdateMemoAlarm: Bool = false
    @State private var isEditing: Bool = false
    @State var editMemo: String
    @State var editTitle: String
    
    //음성 재생용
    @StateObject var audioPlayer = AudioPlayerManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(viewModel.formatDateToKorean(memo.date))")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            if isEditing == true {
                //editTitle 변수를 초기화 할때 따로 만드는 이유
                /// 1) @State로 할 경우 북마크 버튼 클릭해도 DB 값 불러오기X
                /// 2) 기존 memo.title를 @State변수에 할당할 때 Amibiguous use of 'toolbar(content:)' 에러 발생
                TextField("제목", text: $editTitle, axis: .vertical)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
            } else {
                Text(memo.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
            }
            
            Text("요약 키워드")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.mainBlack)
            
            Text(memo.gptContent ?? "요약 없음")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            HStack(alignment: .center, spacing: 10) {
                Button {
                    isVoiceView = true
                } label: {
                    Text("음성기록")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(memo.isVoice == false)
                .hLeading()
                
                Button {
                    isVoiceView = false
                } label: {
                    Text("메모 • 요약")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(memo.isVoice == true)
                .hTrailing()
            }
            .padding(.top)
            
            Divider()
                .padding(.bottom)
            
            if isVoiceView == true || memo.isVoice == true {
                voiceView()
            } else {
                textView()
            }
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if isEditing == true {
                        showUpdateMemoAlarm.toggle()
                    }
                    else { dismiss() }
                }
                label: {
                    Image(systemName: isEditing ? "checkmark" : "arrow.backward")
                        .foregroundColor(Color.mainBlack)
                }
                .alert(isPresented: $showUpdateMemoAlarm) {
                    Alert(
                        title: Text("메모 수정"),
                        message: Text("정말로 메모를 수정하시겠습니까?"),
                        primaryButton: .destructive(Text("수정")) {
                            viewModel.updateMemo(memoId: memo.id, title: editTitle, content: editMemo)
                            isEditing = false
                            dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            if !isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isBookmark.toggle()
                        viewModel.toggleBookmark(memoId: memo.id, isBookmark: viewModel.isBookmark)
                    } label: {
                        Image(systemName: memo.isBookmarked ? "star.fill" : "star")
                            .foregroundColor(memo.isBookmarked ? .mainPink : .mainBlack)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.mainBlack)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showDeleteMemoAlarm.toggle()
                    }
                    label: {
                        Image(systemName: "trash")
                            .foregroundColor(.mainBlack)
                        
                    }
                    .alert(isPresented: $viewModel.showDeleteMemoAlarm) {
                        Alert(
                            title: Text("메모 삭제"),
                            message: Text("정말로 메모를 삭제하시겠습니까?"),
                            primaryButton: .destructive(Text("삭제")) {
                                viewModel.deleteMemo(memoId: memo.id)
                                dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
    }
    
    private func voiceView() -> some View {
        
        VStack(spacing: 20) {
            HStack {
                Text(audioPlayer.currentTimeString)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(audioPlayer.totalTimeString)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Slider(value: $audioPlayer.progress, in: 0...1, onEditingChanged: { editing in
                if !editing {
                    audioPlayer.userSeeked(to: audioPlayer.progress)
                }
            })
            .accentColor(.mainBlack)
            .padding(.horizontal)
            
            Button {
                guard let audioURL = memo.voiceMemoURL else { return }
                
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                }
                else {
                    audioPlayer.play(url: audioURL)
                }
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.mainBlack)
            }
            
            Button {
                audioPlayer.stop()
            } label: {
                Text("다시듣기")
            }
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func textView() -> some View {
        VStack {
            if isEditing == true {
                //editMemo 변수를 초기화 할때 따로 만드는 이유
                /// 1) memo자체를 @State로 할 경우 북마크 버튼 클릭해도 DB 값 불러오기X
                /// 2) 기존 memo.content를 @State변수에 할당할 때 Amibiguous use of 'toolbar(content:)' 에러 발생
                TextField("메모", text: $editMemo, axis: .vertical)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    Text(memo.content)
                        .font(.body)
                }
            }
        }
    }
}

