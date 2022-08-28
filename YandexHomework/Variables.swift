//
//  Variables.swift
//  YandexHomework
//
//  Created by Fedor Penin on 18.08.2022.
//

import Foundation

final class Variables {

    var revision = 53

    var isInited = false

    var token = "UniqueDefensiveArts"

    var isDirty = false

    var isOAuth = false

    static let shared = Variables()

    private init() {}
}
