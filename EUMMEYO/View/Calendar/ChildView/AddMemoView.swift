//
//  AddMemoView.swift
//  EUMMEYO
//
//  Created by 장주진 on 12/24/24.
//

import SwiftUI
import Combine

struct AddMemoView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var container: DIContainer
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    @StateObject private var addMemoViewModel = AddMemoViewModel()
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var recordedCount: Bool = false
    @State private var selectedDate = Date()
    let isVoice: Bool
    
    // 2025년의 날짜 범위
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2025, month: 1, day: 1)
        let endComponents = DateComponents(year: 2025, month: 12, day: 31)
        let startDate = calendar.date(from: startComponents)!
        let endDate = calendar.date(from: endComponents)!
        return startDate...endDate
    }()
    
    // 녹음 시 저장 버튼 활성화
    var canSave: Bool {
        return audioRecorderManager.recordedFileURL != nil
        && audioRecorderManager.isRecording == false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainWhite // 배경터치 시 키보드 자동으로 내림
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }
                VStack(spacing: 20) {
                    
                    // MARK: - 제목 입력 필드 (Monday 스타일 적용)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("제목")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        TextField("메모 제목 입력", text: $title)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                            .padding(.horizontal)
                        
                        DatePicker(
                            "날짜 선택",
                            selection: $selectedDate,
                            in: dateRange,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    }
                    
                    // MARK: - 음성 메모 OR 텍스트 메모
                    if isVoice {
                        VoiceMemoView()
                    } else {
                        MemoTextView()
                    }
                }
                .navigationTitle("새 메모 추가")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    // MARK: - 음성 메모 뷰
    private func VoiceMemoView() -> some View {
        VStack {
            Spacer()
                Button {
                    if audioRecorderManager.isRecording {
                        // 현재 녹음 중이라면 -> Pause
                        audioRecorderManager.pauseRecording()
                    } else if audioRecorderManager.isPaused {
                        // Pause 상태에서 다시 누르면 Resume
                        audioRecorderManager.startRecording()
                    } else {
                        // 녹음 중도 아니고 Pause도 아니면 시작
                        audioRecorderManager.startRecording()
                    }
                } label: {
                    Image(systemName: audioRecorderManager.isRecording ? "pause.fill" : "mic.fill")
                        .font(.system(size: 30))
                        .padding()
                        .foregroundColor(.mainWhite)
                        .background(
                            Circle()
                                .fill(.mainBlack)
                                .frame(width: 100, height: 100)
                        )
                }
            Spacer()
                Text("\(Int(audioRecorderManager.uploadProgress * 100))% 업로드 중")
                    .font(.caption)
                    .foregroundColor(.mainBlack)
                    .animation(.easeInOut, value: audioRecorderManager.uploadProgress)
                    .padding()
            
            Button {
                audioRecorderManager.stopRecording()
                audioRecorderManager.uploadAudioToFirebase(userId: calendarViewModel.userId) { result in
                    switch result {
                    case .success(let url):
                        print("Firebase 저장 성공: \(url)")
                    case .failure(let error):
                        print("Firebase 저장 실패: \(error)")
                    }
                    saveMemo()
                    dismiss()
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("저장하기")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? Color.gray : Color.mainBlack)
                .foregroundColor(.mainWhite)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .disabled(!canSave)
            .opacity(!canSave ? 0.5 : 1.0)
        }
    }
    
    // MARK: - 일반 텍스트 메모 입력 뷰
    private func MemoTextView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("내용")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            TextEditor(text: $content)
                .frame(height: 200)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                .padding(.horizontal)
            Spacer()
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
                .foregroundColor(.mainWhite)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .disabled(content.isEmpty)
            .opacity(content.isEmpty ? 0.5 : 1.0)
        }
    }
    
    // MARK: - 메모 저장 로직
    // ✅ Combine 방식으로 메모 저장
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
                    selectedDate: self.selectedDate,
                    isVoice: self.isVoice,
                    isBookmarked: false,
                    voiceMemoURL: self.audioRecorderManager.recordedFirebaseURL,
                    userId: self.calendarViewModel.userId
                )
                
                container.services.memoService.addMemo(newMemo)
                    .receive(on: DispatchQueue.main)
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

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

