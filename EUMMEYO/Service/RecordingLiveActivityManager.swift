//
//  RecordingLiveActivityManager.swift
//  EUMMEYO
//
//  Created by eunchanKim on 6/1/25.
//
import ActivityKit
import Foundation

final class RecordingLiveActivityManager {
    static let shared = RecordingLiveActivityManager()
    private init() {}
    
    private var activity: Activity<RecordingAttributes>?
    private var startDate: Date?  // ✅ 녹음 시작 시점 저장
    
    func start(title: String, startDate: Date) {
        // ✅ 이미 실행 중이면 새로 만들지 않음
        guard activity == nil else { return }
        
        let attributes = RecordingAttributes(title: title)
        let contentState = RecordingAttributes.ContentState(
            isRecording: true,
            startDate: startDate
        )

        let initialContent = ActivityContent(state: contentState, staleDate: nil)

        Task {
            do {
                activity = try Activity<RecordingAttributes>.request(
                    attributes: attributes,
                    content: initialContent,
                    pushType: nil
                )
                print("✅ Live Activity 시작됨")
            } catch {
                print("❌ Live Activity 시작 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func stop() {
        guard let activity = activity else {
            print("🛑 activity가 nil이라 종료할 수 없습니다.")
            return
        }
        
        let finalState = RecordingAttributes.ContentState(isRecording: false, startDate: Date())
        
        Task {
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate    )
            
            print("🛑 Live Activity 정상 종료됨")
            
            self.activity = nil
        }
    }
    
    func forceStopAll() {
        Task {
            for activity in Activity<RecordingAttributes>.activities {
                await activity.end(
                    ActivityContent(state: .init(isRecording: false, startDate: Date()), staleDate: nil),
                    dismissalPolicy: .immediate
                )
                print("🧹 강제 종료됨: \(activity.id)")
            }
            self.activity = nil
        }
    }
}
