//
//  Date+Extension.swift
//  YandexHomework
//
//  Created by Fedor Penin on 29.07.2022.
//

import Foundation

extension Date {
    var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? Date()
    }

    var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? Date()
    }
}
