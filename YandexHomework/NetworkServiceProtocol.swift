//
//  NetworkServiceProtocol.swift
//  YandexHomework
//
//  Created by Fedor Penin on 12.08.2022.
//

import Foundation

/// Перечисление ошибок обработчика работы с файлами
enum NetworkError: Error {
    case invalidJson
    case undefined
}

protocol NetworkServiceProtocol {

    /// Получить список задач
    /// - Parameter completion: 
    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )

    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )

    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
}
