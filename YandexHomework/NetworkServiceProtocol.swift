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
    func getAllTodoItems() async throws -> [TodoItem]

    /// Изменить задачу
    /// - Parameter item: Задача подлежащая изменению
    /// - Returns: Измененная задача
    func editTodoItem(_ item: TodoItem) async throws -> TodoItem

    /// Удалить задачу
    /// - Parameter id: Уникальный идентификатор задачи
    func deleteTodoItem(at id: String) async throws
}
