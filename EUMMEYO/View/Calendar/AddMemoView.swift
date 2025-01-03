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
                    calendarViewModel.addNewMemo(
                        title: title,
                        content: isVoice ? "음성 메모 내용" : content,
                        isVoice: isVoice
                    )
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
}

#Preview {
    AddMemoView(isVoice: true)
        .environmentObject(CalendarViewModel())
}

