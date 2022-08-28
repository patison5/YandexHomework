//
//  Icon+Extension.swift
//  YandexHomework
//
//  Created by Fedor Penin on 28.07.2022.
//

import UIKit

enum Icon: String {
    case iconArrowDown20
    case iconExclaminationPoint20
    case iconPlusCircleFill

    case iconStatusOff
    case iconStatusOn
    case iconStatusHighPriority

    case iconArrowRight
    case iconCalendar

    case iconInfo
    case iconTrash
}

extension Icon {
    var image: UIImage? {
        return UIImage(named: rawValue)
    }
}
