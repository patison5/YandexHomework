//
//  FileCacheProtocol.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

// Содержит закрытую для внешнего изменения, но открытую для получения коллекцию TodoItem
// Содержит функцию добавления новой задачи
// Содержит функцию удаления задачи (на основе id)
// Содержит функцию сохранения всех дел в файл
// Содержит функцию загрузки всех дел из файла
// Можем иметь несколько разных файлов
// Предусмотреть механизм защиты от дублирования задач (сравниванием id)

import Foundation

// Описание обработчика для работы с файлами
protocol FileCacheProtocol {
    
    /// Список сохраняемых элементов
    var items: [TodoItem] { get }
    
    /// Сохранить элементы в файле
    /// - Parameter file: Название файла
    func pushItems(to file: String) throws
    
    /// Прочитать элементы из файла
    /// - Parameter file: Название файла
    func pullItems(from file: String) throws
    
    /// Добавить новый элемент
    /// - Parameter item: Элемент
    func add(item: TodoItem) throws
    
    /// Удалить элемент из списка
    /// - Parameter id: Уникальный иднетификатор элемента
    func removeItem(by id: String) throws
}
