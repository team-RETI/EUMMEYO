//
//  AddMemoView.swift
//  EUMMEYO
//
//  Created by 장주진 on 12/24/24.
//

import SwiftUI
import Combine

struct AddMemoView: View {
    @StateObject var calendarViewModel : CalendarViewModel
    @EnvironmentObject var container: DIContainer
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    @StateObject private var addMemoViewModel = AddMemoViewModel()
    
    @State private var title: String = ""
    @State private var content: String = ""

    let isVoice: Bool
    
    //fix?
    private let memoDBRepository = MemoDBRepository()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("메모 제목 입력", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if isVoice {
                    VStack {
                        Text(audioRecorderManager.isRecording ? "녹음 중..." : "음성 메모를 추가합니다.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding()
                        
                        Button(audioRecorderManager.isRecording ? "녹음 중지" : "녹음 시작") {
                            if audioRecorderManager.isRecording {
                                audioRecorderManager.stopRecording()
                                content = "녹음완료 (추후에 음성을 텍스트로 변환하는 기능 추가해야함)"
                            } else {
                                audioRecorderManager.startRecording()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(audioRecorderManager.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                } else {
                    TextEditor(text: $content)
                        .frame(height: 200)
                        .border(Color.gray, width: 1)
                        .padding()
                }
                
                Spacer()
                
                Button {
                        saveMemo()
                        dismiss()
                } label: {
                    Text("저장")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(!content.isEmpty ? Color.mainBlack : Color.mainGray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                //fix? 음성메모시 비활성화되는 문제 발생
                .disabled(content.isEmpty)
            }
            .navigationTitle("새 메모 추가")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    // ✅ Combine 방식으로 메모 저장
    private func saveMemo() {
        
        container.services.gptAPIService.summarizeContent(content)
            .receive(on: DispatchQueue.main) // UI 업데이트를 메인 스레드에서 실행
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("메모 저장 성공")
                case .failure(let error):
                    print("메모 저장 실패: \(error)")
                }
            }, receiveValue: {  summary in

                if self.title.isEmpty {
                    self.title = summary
                }
                
                let newMemo = Memo(
                    title: self.title,
                    content: self.content,
                    gptContent: summary,
                    date: Date(),
                    isVoice: self.isVoice,
                    isBookmarked: false,
                    voiceMemoURL: self.audioRecorderManager.recordedFileURL,
                    userId: self.calendarViewModel.userId
                )
                
                container.services.memoService.addMemo(newMemo)
                    .receive(on: DispatchQueue.main) // UI 업데이트를 위해 메인 스레드에서 실행
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure:
                            print("Error")
                        case .finished:
                            self.calendarViewModel.getUserMemos()
                            print("add memo success")
                        }
                    }, receiveValue: {
                        
                    }).store(in: &addMemoViewModel.cancellables)
                })
            .store(in: &addMemoViewModel.cancellables)
    }
}


    /*
    // 메모 저장
    private func saveMemo() {
        
        container.services.gptAPIService.summarizeContent(content) { [self] summary in
            
            if self.title.isEmpty {
                self.title = summary ?? "제목 없음"
            }
            
            let newMemo = Memo(
                title: self.title,
                content: self.content,
                gptContent: summary ?? "요약 실패",
                date: Date(),
                isVoice: self.isVoice,
                isBookmarked: false,
                voiceMemoURL: audioRecorderManager.recordedFileURL,
                userId: calendarViewModel.userId
            )
            
            
            memoDBRepository.addMemo(newMemo)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("메모 저장 성공")
                    case .failure(let error):
                        print("메모 저장 실패: \(error)")
                    }
                }, receiveValue: { _ in
                    print("메모 저장 완료")
                    self.dismiss()
                })
                .store(in: &calendarViewModel.cancellables)
        }
    }
     */



//#Preview {
//    let container: DIContainer
//    AddMemoView(calendarViewModel: CalendarViewModel(container: container, userId: "user1_id"), isVoice: true)
//        .environmentObject(CalendarViewModel(container: .stub, userId: "user1_id"))
//}

