//
//  AddMemoView.swift
//  EUMMEYO
//
//  Created by 장주진 on 12/24/24.
//

import SwiftUI
import Combine

struct AddMemoView: View {
    @AppStorage("isSummary") private var isSummary = false    // 메모요약 상태 가져오기
    
    @StateObject var viewModel: AddMemoViewModel
    
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
    var voiceCanSave: Bool {
        return viewModel.audioManager.recordedFileURL != nil
        && viewModel.audioManager.isRecording == false
        && title.isEmpty == false
    }
    
    // 일반 메모 저장 버튼 활성화
    var textCanSave: Bool {
        return !content.isEmpty && !title.isEmpty
    }
    
    @Environment(\.dismiss) var dismiss
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
                if viewModel.audioManager.isRecording {
                    // 현재 녹음 중이라면 -> Pause
                    viewModel.audioManager.pauseRecord()
                } else if viewModel.audioManager.isPaused {
                    // Pause 상태에서 다시 누르면 Resume
                    viewModel.audioManager.startRecord()
                } else {
                    // 녹음 중도 아니고 Pause도 아니면 시작
                    viewModel.audioManager.startRecord()
                }
            } label: {
                Image(systemName: viewModel.isRecording ? "pause.fill" : "mic.fill")
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
            Text("\(Int(viewModel.uploadProgress * 100))% 업로드 중")
                .font(.caption)
                .foregroundColor(.mainBlack)
                .animation(.easeInOut, value: viewModel.audioManager.uploadProgress)
                .padding()
            
            Toggle("요약 모드 (사용횟수: \(viewModel.user.currentUsage)/\(viewModel.user.maxUsage))",isOn: $isSummary)
                .font(.subheadline)
                .foregroundColor(.gray)
                .toggleStyle(SwitchToggleStyle(tint: .mainPink))
                .padding()
            
            Spacer()
            
            Button {
                viewModel.audioManager.stopRecord()
                viewModel.audioManager.uploadAudioToFirebase(userId: viewModel.user.id) { result in
                    switch result {
                    case .success(let url):
                        print("Firebase 저장 성공: \(url)")
                    case .failure(let error):
                        print("Firebase 저장 실패: \(error)")
                    }
                    
                    // MARK: - 음성메모
                    viewModel.saveVoiceMemo(memo: Memo(
                        title: self.title,
                        content: self.content,
                        gptContent: nil,
                        date: Date(),
                        selectedDate: self.selectedDate,
                        isVoice: self.isVoice,
                        isBookmarked: false,
                        voiceMemoURL: viewModel.audioManager.recordedFirebaseURL,
                        userId: self.viewModel.user.id
                    ), isSummary: isSummary)
                    /// 유저가 선택한 날짜로 캘린더 이동
                    //                        viewModel.updateCalendar(to: selectedDate)
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
                .background(voiceCanSave ? Color.mainBlack : Color.gray)
                .foregroundColor(.mainWhite)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .disabled(!voiceCanSave)
            .opacity(!voiceCanSave ? 0.5 : 1.0)
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
            
            Toggle("요약 모드 (사용횟수: \(viewModel.user.currentUsage)/\(viewModel.user.maxUsage))",isOn: $isSummary)
                .font(.subheadline)
                .foregroundColor(.gray)
                .toggleStyle(SwitchToggleStyle(tint: .mainPink))
                .padding()
            
            Spacer()
            Button {

                viewModel.saveTextMemo(memo: Memo(
                    title: self.title,
                    content: self.content,
                    gptContent: nil,
                    date: Date(),
                    selectedDate: self.selectedDate,
                    isVoice: self.isVoice,
                    isBookmarked: false,
                    voiceMemoURL: viewModel.audioManager.recordedFirebaseURL,
                    userId: self.viewModel.user.id
                ), isSummary: isSummary)
                /// 유저가 선택한 날짜로 캘린더 이동
                //                viewModel.updateCalendar(to: selectedDate)
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("저장하기")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(textCanSave ? Color.mainBlack : Color.gray)
                .foregroundColor(.mainWhite)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .disabled(!textCanSave)
            .opacity(!textCanSave ? 0.5 : 1.0)
        }
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

