//
//  AddMemoViewModel.swift
//  EUMMEYO
//
//  Created by 김동현 on 2/11/25.
//

import SwiftUI
import Combine

final class AddMemoViewModel: ObservableObject {
    
    @ObservedObject var memoStore: MemoStore
    @ObservedObject var userStore: AuthenticationViewModel
    var cancellables = Set<AnyCancellable>()
    private var container: DIContainer
    var audioManager = AudioRecorderRepository.shared
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordedFileURL: URL? // 저장된 파일 경로
    @Published var recordedFirebaseURL: URL? // 저장된 파일 경로
    @Published var uploadProgress: Double = 0.0  // 0.0 ~ 1.0
    
    /// 뷰에서 사용하는 변수
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedDate = Date()
    
    @Published var user: User
    
    init(memoStore: MemoStore, userStore: AuthenticationViewModel, container: DIContainer) {
        self.memoStore = memoStore
        self.userStore = userStore
        self.container = container
        self.user = userStore.user!
        
        // audioRecorderManager의 isRecording 변화를 감지해서 CalendarViewModel에 반영
        audioManager.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.isRecording = newValue
            }
            .store(in: &cancellables)
        
        audioManager.$uploadProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.uploadProgress = newValue
            }
            .store(in: &cancellables)
        
        audioManager.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.title = newValue
            }
            .store(in: &cancellables)
        
        audioManager.$content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.content = newValue
            }
            .store(in: &cancellables)
    }
    
//    // MARK: - User정보 가져오는 함수
    func getUser() {
        container.services.userService.getUser(userId: user.id)
            .sink { completion in
                switch completion {
                case .failure:
                    print("Error")
                case .finished:
                    print("유저 정보 가져오기 성공")
                }
            } receiveValue: { user in
                self.user = user
            }.store(in: &cancellables)
    }
    
    // MARK: - 일반 메모 저장 함수
    func saveTextMemo(memo: Memo, isSummary: Bool) {
        if isSummary { // 요약모드 ON
            container.services.gptAPIService.summarizeContent(memo.content)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("GPT 요약 성공")
                    case .failure(let error):
                        print("GPT 요약 성공 실패: \(error)")
                    }
                }, receiveValue: { summary in
                    
                    let newMemo = Memo(
                        title: memo.title,
                        content: memo.content,
                        gptContent: summary,
                        date: Date(),
                        selectedDate: memo.selectedDate,
                        isVoice: memo.isVoice,
                        isBookmarked: false,
                        voiceMemoURL: self.audioManager.recordedFirebaseURL,
                        userId: self.user.id
                    )
                    self.container.services.memoService.addMemo(newMemo)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("텍스트 요약모드 메모 저장 성공")
                            case .failure(let error):
                                print("텍스트 요약모드 메모 저장 실패 : \(error)")
                            }
                        }, receiveValue: {
                            self.incrementUsage()
                        })
                        .store(in: &self.cancellables)
                })
                .store(in: &cancellables)
            
        } else { // 요약모드 OFF
            let newMemo = Memo(
                title: memo.title,
                content: memo.content,
                gptContent: nil,
                date: Date(),
                selectedDate: memo.selectedDate,
                isVoice: memo.isVoice,
                isBookmarked: false,
                voiceMemoURL: self.audioManager.recordedFirebaseURL,
                userId: self.user.id
            )
            container.services.memoService.addMemo(newMemo)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("텍스트 메모 저장 성공")
                    case .failure(let error):
                        print("텍스트 메모 저장 실패 : \(error)")
                    }
                }, receiveValue: { })
                .store(in: &cancellables)
        }
    }
    
    // MARK: - 음성 메모 저장 함수
    func saveVoiceMemo(memo: Memo, isSummary: Bool) {
        guard let serverURL = audioManager.recordedFirebaseURL else {
            print("🔥 오류: firebase 녹음 파일 URL 없음")
            return
        }
        
        var newMemo = Memo(
            title: memo.title,
            content: "음성 인식 중...",
            gptContent: "요약 중...",
            date: Date(),
            selectedDate: memo.selectedDate,
            isVoice: true,
            isBookmarked: false,
            voiceMemoURL: serverURL,
            userId: self.user.id
        )
        
        // UI 즉시 반영
        self.addMemoLocallyAndUpload(newMemo)
        
        // DB에 우선 저장
        self.uploadMemo(newMemo)
        
        if isSummary { // 요약모드 ON
            // 백그라운드에서 텍스트 변환 + 요약 처리
            container.services.gptAPIService.audioToTextGPT(url: serverURL)
                .flatMap { [weak self] transcription -> AnyPublisher<(String, String), ServiceError> in
                    guard let self else {
                        return Fail(error: .invalidData).eraseToAnyPublisher()
                    }
                    return self.container.services.gptAPIService.summarizeContent(transcription)
                        .map { summary in (transcription, summary) }
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("🎉 음성 텍스트 변환 + 요약 성공")
                    case .failure(let error):
                        print("🔥 요약 실패: \(error)")
                    }
                }, receiveValue: { [self] transcription, summary in
                    
                    // 업데이트된 메모 생성
                    newMemo.content = transcription
                    newMemo.gptContent = summary
                    
                    // 해당 메모 업데이트 처리
                    self.updateMemo(newMemo)
                    
                    // 클린업
                    self.incrementUsage()
                    self.uploadProgress = 0.0
                    self.recordedFileURL = nil
                    self.recordedFirebaseURL = nil
                })
                .store(in: &cancellables)
            
        } else { // 요약모드 OFF
            newMemo.content = "요약이 없습니다."
            newMemo.gptContent = "요약이 없습니다"
            
            self.updateMemo(newMemo)
            self.uploadProgress = 0.0
            self.recordedFileURL = nil
            self.recordedFirebaseURL = nil
            
        }
    }
    
    // MARK: - 로컬UI 업데이트 함수
    func addMemoLocallyAndUpload(_ memo: Memo) {
        self.memoStore.memoList.insert(memo, at: 0)
    }
    
    // MARK: - Firebase 저장
    func uploadMemo(_ memo: Memo) {
        container.services.memoService.addMemo(memo)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("메모 업로드 실패: \(error)")
                }
            }, receiveValue: {
                print("메모 업로드 성공")
            })
            .store(in: &cancellables)
    }
    // MARK: - 메모 백그라운드로 업데이트
    func updateMemo(_ memo: Memo) {
        container.services.memoService.updateMemo(memoId: memo.id, memo: memo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("메모 업데이트 실패: \(error)")
                }
            }, receiveValue: {
                print("메모 업데이트 성공")
            })
            .store(in: &cancellables)
    }
    
    func incrementUsage() {
        container.services.userService.updateUserCount(userId: user.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("사용량 업데이트 성공")
                    /// 추후에 User 객체도 스냅샷으로 만들예정
                    self.getUser() // 업데이트된 사용자 정보 다시 가져오기
                case .failure(let error):
                    print("사용량 업데이트 실패: \(error)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
}
