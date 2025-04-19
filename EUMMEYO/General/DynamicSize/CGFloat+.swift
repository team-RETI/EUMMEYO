//
//  CGFloat+.swift
//  EUMMEYO
//
//  Created by 김동현 on 4/19/25.
//

import Foundation

extension CGFloat {
    var scaled: CGFloat {
        return DynamicSize.scaledSize(self)
    }
}


