//
//  FileCacheProtocol.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import Foundation

// Описание обработчика для работы с файлами
protocol FileCacheProtocol {

    /// Список сохраняемых элементов
    var items: [TodoItem] { get }

    /// Сохранить элементы в файле
    /// - Parameter file: Название файла
    func saveItems(to file: String) throws

    /// Прочитать элементы из файла
    /// - Parameter file: Название файла
    func loadItems(from file: String) throws

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
}
