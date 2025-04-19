//
//  CGDouble+.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/19/25.
//

import Foundation

extension Double {
    var scaled: CGFloat {
        return DynamicSize.scaledSize(CGFloat(self))
    }
}
