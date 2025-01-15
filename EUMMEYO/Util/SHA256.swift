//
//  SHA256.swift
//  EUMMEYO
//
//  Created by 김동현 on 1/3/25.
//

import Foundation
import CryptoKit

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap { String(format: "02x", $0) }.joined()
    
    return hashString
}
