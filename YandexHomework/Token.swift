//
//  ColorExtension.swift
//  YandexHomework
//
//  Created by Fedor Penin on 28.07.2022.
//

import UIKit

enum Token: String {
    case red = "red"
    case green = "green"
    case blue = "blue"
    case gray = "gray"
    case light = "light"
    case white = "white"

    case backIOSPrimary = "backIOSPrimary"
    case backPrimary = "backPrimary"
    case backSecondary = "backSecondary"
    case backElevated = "backElevated"

    case labelPrimary = "labelPrimary"
    case labelTertiary = "labelTertiary"
    case labelSecondary = "labelSecondary"
    case labelDisable = "labelDisable"

    case supportNavBarBlur = "supportNavBarBlur"
    case supportOverlay = "supportOverlay"
    case supportSeparator = "supportSeparator"
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
