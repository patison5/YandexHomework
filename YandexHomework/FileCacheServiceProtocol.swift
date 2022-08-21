//
//  FileCacheProtocol.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import Foundation

// Описание обработчика для работы с файлами
protocol FileCacheServiceProtocol {

    /// Список сохраняемых элементов
    var items: [TodoItem] { get }

    /// Добавить новый элемент
    /// - Parameter item: Элемент
    func add(item: TodoItem) throws

    /// Удалить элемент из списка
    /// - Parameter id: Уникальный иднетификатор элемента
    func removeItem(by id: String) throws

    /// Найти задачу
    /// - Parameter id: айди задачи
    /// - Returns: Найденная задача, если существует
    func get(by id: String) -> TodoItem?

    /// Изменить элемент
    /// - Parameter item: Новый элемент
    func change(item: TodoItem) throws

    /// Сохранить таски в файл
    /// - Parameters:
    ///   - file: Название файла
    ///   - completion: Блок действий по заврешении операции
    func save(to file: String) async throws

    /// Загрузить таски из файла
    /// - Parameters:
    ///   - file: Название файла
    ///   - completion: Блок действий по заврешении операции
    func load(from file: String) async throws -> [TodoItem]
}
