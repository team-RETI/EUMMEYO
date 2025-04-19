//
//  BasicDevice.swift
//  ScaleKit
//
//  Created by 김동현 on 4/19/25.
//

import CoreGraphics

/// 기준 디바이스 종류 (논리 해상도 기준)
public enum BaseDevice {
    
    // MARK: - iPhone SE / 8 시리즈
    case iPhoneSE2
    case iPhoneSE3
    case iPhone8Plus

    // MARK: - iPhone X ~ 11 시리즈
    case iPhoneX
    case iPhoneXR
    case iPhone11
    case iPhone11ProMax

    // MARK: - iPhone 12 시리즈
    case iPhone12
    case iPhone12Mini
    case iPhone12Pro
    case iPhone12ProMax

    // MARK: - iPhone 13 시리즈
    case iPhone13
    case iPhone13Mini
    case iPhone13Pro
    case iPhone13ProMax

    // MARK: - iPhone 14 시리즈
    case iPhone14
    case iPhone14Plus
    case iPhone14Pro
    case iPhone14ProMax

    // MARK: - iPhone 15 시리즈
    case iPhone15
    case iPhone15Plus
    case iPhone15Pro
    case iPhone15ProMax

    // MARK: - iPhone 16 시리즈
    case iPhone16
    case iPhone16Plus
    case iPhone16Pro
    case iPhone16ProMax

    public var size: CGSize {
        switch self {
        // iPhone SE / 8
        case .iPhoneSE2, .iPhoneSE3:       return CGSize(width: 375, height: 667)
        case .iPhone8Plus:                 return CGSize(width: 414, height: 736)

        // iPhone X ~ 11
        case .iPhoneX:                     return CGSize(width: 375, height: 812)
        case .iPhoneXR, .iPhone11:         return CGSize(width: 414, height: 896)
        case .iPhone11ProMax:              return CGSize(width: 414, height: 896)

        // iPhone 12
        case .iPhone12, .iPhone12Pro:      return CGSize(width: 390, height: 844)
        case .iPhone12Mini:                return CGSize(width: 360, height: 780)
        case .iPhone12ProMax:              return CGSize(width: 428, height: 926)

        // iPhone 13
        case .iPhone13, .iPhone13Pro:      return CGSize(width: 390, height: 844)
        case .iPhone13Mini:                return CGSize(width: 375, height: 812)
        case .iPhone13ProMax:              return CGSize(width: 428, height: 926)

        // iPhone 14
        case .iPhone14:                    return CGSize(width: 390, height: 844)
        case .iPhone14Plus:                return CGSize(width: 428, height: 926)
        case .iPhone14Pro:                 return CGSize(width: 393, height: 852)
        case .iPhone14ProMax:              return CGSize(width: 430, height: 932)

        // iPhone 15
        case .iPhone15:                    return CGSize(width: 393, height: 852)
        case .iPhone15Plus:                return CGSize(width: 430, height: 932)
        case .iPhone15Pro:                 return CGSize(width: 393, height: 852)
        case .iPhone15ProMax:              return CGSize(width: 430, height: 932)

        // iPhone 16
        case .iPhone16:                    return CGSize(width: 393, height: 852)
        case .iPhone16Plus:                return CGSize(width: 430, height: 932)
        case .iPhone16Pro:                 return CGSize(width: 402, height: 874)
        case .iPhone16ProMax:              return CGSize(width: 440, height: 956)
        }
    }
}

