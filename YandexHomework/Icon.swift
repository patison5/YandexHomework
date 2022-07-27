//
//  Icon+Extension.swift
//  YandexHomework
//
//  Created by Fedor Penin on 28.07.2022.
//

import UIKit

enum Icon: String {
    case iconArrowDown20 = "iconArrowDown20"
    case iconExclaminationPoint20 = "iconExclaminationPoint20"
    case iconPlusCircleFill = "iconPlusCircleFill"

    case iconStatusOff = "iconStatusOff"
    case iconStatusOn = "iconStatusOn"
    case iconStatusHighPriority = "iconStatusHighPriority"

    case iconArrowRight = "iconArrowRight"
    case iconCalendar = "iconCalendar"

    case iconInfo = "iconInfo"
    case iconTrash = "iconTrash"
}

extension Icon {
    var image: UIImage? {
        return UIImage(named: rawValue)
    }
}
