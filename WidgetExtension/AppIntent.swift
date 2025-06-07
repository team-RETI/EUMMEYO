//
//  AppIntent.swift
//  WidgetExtension
//
//  Created by eunchanKim on 6/1/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Start Recording"

    func perform() async throws -> some ProvidesDialog {
        // 여기에 실제 녹음 시작 로직 추가
        return .result(dialog: "Recording started.")
    }
}
