//
//  FileCacheError.swift
//  Homework
//
//  Created by Fedor Penin on 27.07.2022.
//

import Foundation

/// Перечисление ошибок обработчика работы с файлами
enum FileCacheError: Error {
    case invalidJson
    case noDocumentDirectory
    case itemAlreadyExist
}

enum HomeViewModelError: Error {
    case suchIdDoesntExist
}
