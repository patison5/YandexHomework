//
//  FileCacheProtocol.swift
//  YandexHomework
//
//  Created by Fedor Penin on 22.08.2022.
//

import Foundation

protocol FileCacheProtocol {

    /// Список сохраняемых элементов
    var items: [TodoItem] { get }

    /// Добавить новый элемент
    /// - Parameter item: Элемент
    func add(item: TodoItem) throws

    /// Удалить элемент из списка
    /// - Parameter id: Уникальный иднетификатор элемента
    func remove(by id: String) throws

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
    func save(to file: String) throws

    /// Загрузить таски из файла
    /// - Parameters:
    ///   - file: Название файла
    func load(from file: String) throws -> [TodoItem]
}
