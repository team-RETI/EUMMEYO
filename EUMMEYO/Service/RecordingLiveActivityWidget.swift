//
//  RecordingLiveActivityWidget.swift
//  EUMMEYO
//
//  Created by eunchanKim on 6/1/25.
//

//import WidgetKit
//import SwiftUI
////import ActivityKit
//
////@main
//struct RecordingLiveActivityWidget: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: RecordingAttributes.self) { context in
//            // Lock screen / banner
//            VStack(alignment: .leading) {
//                Text("녹음 중: \(context.attributes.title)")
//                    .font(.headline)
//                Text("경과 시간: \(Int(context.state.elapsedTime))초")
//                    .font(.caption)
//            }
//            .padding()
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded
//                DynamicIslandExpandedRegion(.leading) {
//                    Image(systemName: "mic.fill")
//                        .foregroundColor(.red)
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("\(Int(context.state.elapsedTime))초")
//                        .font(.headline)
//                        .monospacedDigit()
//                }
//                DynamicIslandExpandedRegion(.center) {
//                    Text(context.attributes.title)
//                        .font(.subheadline)
//                        .lineLimit(1)
//                }
//            } compactLeading: {
//                Image(systemName: "mic.fill")
//            } compactTrailing: {
//                Text("\(Int(context.state.elapsedTime))s")
//            } minimal: {
//                Image(systemName: "mic.fill")
//            }
//            .keylineTint(.red)
//        }
//    }
//}
