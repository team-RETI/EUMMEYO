//
//  VersionManager.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/29/25.
//

import Foundation
import SwiftUI

final class VersionManager: ObservableObject {
    static let shared = VersionManager()

    @Published var showUpdateAlert = false
    @Published var latestVersion: String?

    private init() {}

    func checkForAppUpdates(bundleId: String) {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        fetchLatestVersionFromAppStore(bundleId: bundleId) { latest in
            DispatchQueue.main.async {
                if let latest = latest, self.isUpdateRequired(currentVersion: currentVersion, latestVersion: latest) {
                    self.latestVersion = latest
                    self.showUpdateAlert = true
                }
            }
        }
    }

    private func fetchLatestVersionFromAppStore(bundleId: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let latestVersion = results.first?["version"] as? String {
                    completion(latestVersion)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }

    private func isUpdateRequired(currentVersion: String, latestVersion: String) -> Bool {
        return currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending
    }
}
