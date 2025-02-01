//
//  AddMemoView.swift
//  EUMMEYO
//
//  Created by 장주진 on 12/24/24.
//

import SwiftUI

struct AddMemoView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var container: DIContainer
    
    @Environment(\.dismiss) var dismiss

    @StateObject private var audioRecorderManager = AudioRecorderManager()
    @State private var title: String = ""
    @State private var content: String = ""
    let isVoice: Bool

    private let memoDBRepository = MemoDBRepository()
    private let gptService = GPTAPIService()

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

                Button("저장") {
                    saveMemo()
                    calendarViewModel.filterTodayMemos()
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .navigationTitle("새 메모 추가")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // 메모 저장
    private func saveMemo() {
        gptService.summarizeContent(content) { [self] summary in
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
}


#Preview {
    AddMemoView(isVoice: true)
        .environmentObject(CalendarViewModel(container: .stub, userId: "user1_id"))
}

