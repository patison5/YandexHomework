//
//  FileCacheProtocol.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import Foundation

// Описание обработчика для работы с файлами
protocol FileCacheProtocol {

    /// Прочитать элементы из файла
    func load() throws -> [TodoItem]

    /// Добавить новый элемент
    /// - Parameter item: Элемент
    func add(item: TodoItem) throws

    /// Добавить набор элементов в таблицу одним запросом
    /// - Parameter items: Набор элементов
    func add(items: [TodoItem]) throws

    /// Удалить элемент из списка
    /// - Parameter id: Уникальный иднетификатор элемента
    func remove(by id: String) throws

    /// Изменить элемент
    /// - Parameter item: Новый элемент
    func change(item: TodoItem) throws

    /// Очистить всю таблицу
    func dropTable() throws
}
