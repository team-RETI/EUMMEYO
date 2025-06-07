//
//  RecordingLiveActivitiyWidget.swift
//  WidgetExtension
//
//  Created by eunchanKim on 6/6/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isRecording: Bool
        var startDate: Date
    }
    
    var title: String
}

struct RecordingLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingAttributes.self) { context in
            VStack(spacing: -3) {
                Spacer(minLength: 14)
                Text("Eummeyo")
                    .colorMultiply(.mainGray)
                Text(context.state.startDate, style: .timer)
                    .multilineTextAlignment(.center)
                    .monospacedDigit()
                    .font(.system(size: 44, weight: .semibold))
                    .colorMultiply(.mainPink)
                Spacer()
            }
            .background(.black.opacity(0.6))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("Eummeyo")
                        .font(.system(size: 10, weight: .light))
                        .colorMultiply(.mainGray)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.startDate, style: .timer)
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .font(.system(size: 44, weight: .semibold))
                        .colorMultiply(.mainPink)
                }
                
            } compactLeading: {
                Image(systemName: "mic.fill")
                    .renderingMode(.template)
                    .colorMultiply(.mainPink)
                    .frame(width: 30)
            } compactTrailing: {
                Text(context.state.startDate, style: .timer)
                    .monospacedDigit()
                    .frame(width: 30)
                    .font(.system(size: 12.7, weight: .semibold))
                    .foregroundColor(.mainPink)
                
            } minimal: {
                Image(systemName: "waveform")
                    .renderingMode(.template)
                    .colorMultiply(.mainPink)
            }
        }
    }
}
