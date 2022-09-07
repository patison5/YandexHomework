//
//  FileCacheProtocol.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import Foundation

// Описание обработчика для работы с файлами
protocol FileCacheServiceProtocol {

    /// Добавить новый элемент
    /// - Parameter item: Элемент
    func add(item: TodoItem) throws

    /// Удалить элемент из списка
    /// - Parameter id: Уникальный иднетификатор элемента
    func remove(by id: String) throws

    /// Изменить элемент
    /// - Parameter item: Новый элемент
    func change(item: TodoItem) throws

    /// Обновить базу значений смерженным набором элементов
    /// - Parameter items: Набор элементов
    func patch(by items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void)

    /// Загрузить таски из файла
    /// - Parameters:
    ///   - completion: Блок действий по заврешении операции
    func load(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
}
