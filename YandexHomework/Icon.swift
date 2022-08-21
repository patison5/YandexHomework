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
}

extension Icon {
    var image: UIImage? {
        return UIImage(named: rawValue)
    }
}

