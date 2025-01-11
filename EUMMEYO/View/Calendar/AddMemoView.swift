//
//  AddMemoView.swift
//  EUMMEYO
//
//  Created by 장주진 on 12/24/24.
//

import SwiftUI

struct AddMemoView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @Environment(\.dismiss) var dismiss

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
                    Text("음성 메모를 추가합니다.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding()
                } else {
                    TextEditor(text: $content)
                        .frame(height: 200)
                        .border(Color.gray, width: 1)
                        .padding()
                }

                Spacer()

                Button("저장") {
                    saveMemo()
                    calendarViewModel.filterTodayMemos() //캘린더뷰 새로고침 -> 바로 볼 수 있게?
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
    
    private func saveMemo() {
        // 1️⃣ 먼저 GPT API로 content 요약
        gptService.summarizeContent(content) { [self] summary in
            // 2️⃣ 요약된 내용을 사용해서 Memo 객체 생성
            let newMemo = Memo(
                title: self.title,
                content: self.content,
                gptContent: summary ?? "요약 실패",
                date: Date(),
                isVoice: self.isVoice,
                isBookmarked: false
            )
            
            // 3️⃣ Firebase에 저장
            self.memoDBRepository.addMemo(newMemo)
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
                .store(in: &self.calendarViewModel.cancellables)
        }
    }
}

#Preview {
    AddMemoView(isVoice: true)
        .environmentObject(CalendarViewModel())
}

