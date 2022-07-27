//
//  DispatchQueue.swift
//  YandexHomework
//
//  Created by Fedor Penin on 18.08.2022.
//

import Foundation

extension DispatchQueue {

    static func main(closure: (() -> Void)) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync {
                closure()
            }
        }
    }
}
