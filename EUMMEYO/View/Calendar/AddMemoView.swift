//
//  AddMemoView.swift
//  EUMMEYO
//
//  Created by 장주진 on 12/24/24.
//

import SwiftUI
import Combine

struct AddMemoView: View {
    @StateObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var container: DIContainer
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    @StateObject private var addMemoViewModel = AddMemoViewModel()
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var recordedCount: Bool = false
    let isVoice: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                

                // MARK: - 제목 입력 필드 (Monday 스타일 적용)
                VStack(alignment: .leading, spacing: 5) {
                    Text("제목")
                        .font(.headline)
                        .foregroundColor(.gray)
//
//                if isVoice {
//                    VStack {
//                        Text(audioRecorderManager.isRecording ? "녹음 중..." : "음성 메모를 추가합니다.")
//                            .foregroundColor(.gray)
//                            .font(.subheadline)
//                            .padding()
//                        
//                        Button(audioRecorderManager.isRecording ? "녹음 중지" : "녹음 시작") {
//                            if audioRecorderManager.isRecording {
//                                audioRecorderManager.stopRecording()
//                                recordedCount = true
////                                content = "녹음완료 (추후에 음성을 텍스트로 변환하는 기능 추가해야함)"
//
//                            } else {
//                                audioRecorderManager.startRecording()
//                            }
//                        }
//>>>>>>> d00c6fd7709d6f8f9f9cc45708fc536ac8411bc4
                        .padding()
                    
                    TextField("메모 제목 입력", text: $title)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                        .padding(.horizontal)
//<<<<<<< HEAD
                }
                
                // MARK: - 음성 메모 OR 텍스트 메모
                if isVoice {
                    VoiceMemoView()
                } else {
                    MemoTextView()
//=======
//        
//                        Button {
//                            audioRecorderManager.uploadAudioToFirebase(userId: calendarViewModel.userId)
//                            
//                        } label: {
//                            Text("음성 업로드")
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(audioRecorderManager.isRecording || recordedCount == false ? Color.mainGray : Color.green)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
//                                .padding(.horizontal)
//                        }
//                        .disabled(audioRecorderManager.isRecording || recordedCount == false)
//
//                        Spacer()
//                        
//                        Button {
//                                saveMemo()
//                                dismiss()
//                            
//                        } label: {
//                            Text("저장")
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(audioRecorderManager.memoURL != nil ? Color.mainBlack : Color.mainGray)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
//                                .padding(.horizontal)
//                        }
//                        .disabled(audioRecorderManager.memoURL == nil)
//                    }
//                } else {
//                    TextEditor(text: $content)
//                        .frame(height: 200)
//                        .border(Color.gray, width: 1)
//                        .padding()
//                    
//                    Button {
//                            saveMemo()
//                            dismiss()
//                    } label: {
//                        Text("저장")
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(!content.isEmpty ? Color.mainBlack : Color.mainGray)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                            .padding(.horizontal)
//                    }
//                    .disabled(content.isEmpty)
//>>>>>>> d00c6fd7709d6f8f9f9cc45708fc536ac8411bc4
                }
                Spacer()
//<<<<<<< HEAD
                
                // MARK: - 저장 버튼
                Button {
                    saveMemo()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("저장하기")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(content.isEmpty ? Color.gray : Color.mainBlack)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(content.isEmpty)
                .opacity(content.isEmpty ? 0.5 : 1.0)
//=======
//>>>>>>> d00c6fd7709d6f8f9f9cc45708fc536ac8411bc4
            }
            .padding(.top)
            .navigationTitle("새 메모 추가")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
//<<<<<<< HEAD
    // MARK: - 음성 메모 뷰
    private func VoiceMemoView() -> some View {
        VStack {
            Text(audioRecorderManager.isRecording ? "녹음 중..." : "음성 메모를 추가합니다.")
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding()
            
            HStack {
                Spacer()
                
                Button {
                    if audioRecorderManager.isRecording {
                        audioRecorderManager.stopRecording()
                        content = "녹음완료 (추후 음성을 텍스트 변환 기능 추가)"
                    } else {
                        audioRecorderManager.startRecording()
                    }
                } label: {
                    Image(systemName: audioRecorderManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(audioRecorderManager.isRecording ? Color.red : Color.black)
                                .frame(width: 80, height: 80)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                }
                
                Spacer()
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - 일반 텍스트 메모 입력 뷰
    private func MemoTextView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("내용")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
            
            TextEditor(text: $content)
                .frame(height: 200)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                .padding(.horizontal)
        }
    }
    
    // MARK: - 메모 저장 로직
//=======
//    // ✅ Combine 방식으로 메모 저장
//>>>>>>> d00c6fd7709d6f8f9f9cc45708fc536ac8411bc4
    private func saveMemo() {
        container.services.gptAPIService.summarizeContent(content)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("메모 저장 성공")
                case .failure(let error):
                    print("메모 저장 실패: \(error)")
                }
            }, receiveValue: { summary in
                
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
                    voiceMemoURL: self.audioRecorderManager.memoURL,
                    userId: self.calendarViewModel.userId
                )
                
                container.services.memoService.addMemo(newMemo)
                    .receive(on: DispatchQueue.main)
//<<<<<<< HEAD
//=======
//                    .flatMap { _ -> AnyPublisher<Void, ServiceError> in
//                        Future<Void, ServiceError> { promise in
//                            self.calendarViewModel.incrementUsage()
//                            promise(.success(()))
//                        }.eraseToAnyPublisher()
//                    }
//>>>>>>> d00c6fd7709d6f8f9f9cc45708fc536ac8411bc4
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure:
                            print("Error")
                        case .finished:
                            self.calendarViewModel.getUserMemos()
                            print("add memo success")
                        }
                    }, receiveValue: {})
                    .store(in: &addMemoViewModel.cancellables)
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



#Preview {
    let container = DIContainer.stub
    return AddMemoView(calendarViewModel: CalendarViewModel(container: container, userId: "user1_id"), isVoice: true)
        .environmentObject(container)
}


