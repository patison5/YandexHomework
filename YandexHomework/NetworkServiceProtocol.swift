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

    // MARK: - Public working methods

    /// Получить данные с сервера
    /// - Parameter completion: Колбэк
    func get(completion: @escaping (Result<ApiTodoListModel, Error>) -> Void)

    /// Смержить данные задач с сервером
    /// - Parameters:
    ///   - list: Набор задач
    ///   - completion: Колбэк
    func patch(
        with list: ApiTodoListModel,
        completion: @escaping (Result<ApiTodoListModel, Error>) -> Void
    )

    /// Удалить задачу с сервера
    /// - Parameters:
    ///   - id: Уникальный идентификатор задачи
    ///   - completion: Колбэк
    func delete(
        by id: String,
        completion: @escaping (Result<ApiTodoElementModel, Error>) -> Void
    )

    /// Обновить задачу на сервере
    /// - Parameters:
    ///   - element: Бизнес модель задачи
    ///   - completion: Колбэк
    func update(
        by element: ApiTodoElementModel,
        completion: @escaping (Result<ApiTodoElementModel, Error>) -> Void
    )

    /// Добавить новую задачу
    /// - Parameters:
    ///   - element: Бизнес модель задачи
    ///   - completion: Колбэк
    func add(
        by element: ApiTodoElementModel,
        completion: @escaping (Result<ApiTodoElementModel, Error>) -> Void
    )
}
