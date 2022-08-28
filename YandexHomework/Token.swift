//
//  ColorExtension.swift
//  YandexHomework
//
//  Created by Fedor Penin on 28.07.2022.
//

import UIKit

enum Token: String {
    case red
    case green
    case blue
    case gray
    case light
    case white
    case grayLight

    case backIOSPrimary
    case backPrimary
    case backSecondary
    case backElevated

    case labelPrimary
    case labelTertiary
    case labelSecondary
    case labelDisable

    case supportNavBarBlur
    case supportOverlay
    case supportSeparator
}

extension Token {
    var color: UIColor {
        guard let color = UIColor(named: rawValue) else {
            print("❌ Цвет \(rawValue) не найден. Использую цвет по умолчанию .black")
            return .black
        }
        return color
    }

    /// Динамический цвет CoreGraphics
    var cgColor: CGColor { color.cgColor }
}
