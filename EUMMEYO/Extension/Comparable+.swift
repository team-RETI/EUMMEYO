//
//  ㅇㅇ.swift
//  EUMMEYO
//
//  Created by eunchanKim on 5/21/25.
//

import SwiftUI

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
