//
//  FileCache.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

// FileCache
//
// Содержит закрытую для внешнего изменения, но открытую для получения коллекцию TodoItem
// Содержит функцию добавления новой задачи
// Содержит функцию удаления задачи (на основе id)
// Содержит функцию сохранения всех дел в файл
// Содержит функцию загрузки всех дел из файла
// Можем иметь несколько разных файлов
// Предусмотреть механизм защиты от дублирования задач (сравниванием id)


import Foundation

final class FileCache {
    
    
    // MARK: - FileCacheProtocol Properties
    
    var items: [TodoItem] = []
    
    
    // MARK: - Private Properties
    
    private let fileName: String
    
    
    // MARK: - Init
    
    init(fileName: String) {
        self.fileName = fileName
    }
}


// MARK: - FileCacheProtocol

extension FileCache: FileCacheProtocol {
    
    func add(item: TodoItem) throws {
        if items.first(where: { $0.id == item.id }) != nil {
            throw FileCacheError.noDocumentDirectory
        }
        
        items.append(item)
        try pushItems(to: fileName)
    }
    
    func removeItem(by id: String) throws {
        items.removeAll { item in
            return item.id == id
        }
        try pushItems(to: fileName)
    }
    
    func pushItems(to file: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.noDocumentDirectory
        }
        let pathWithFilename = documentDirectory.appendingPathComponent(file)
        let jsonString = convertObjectsIntoString()
        try jsonString.write(to: pathWithFilename, atomically: true, encoding: .utf8)
    }
    
    func pullItems(from file: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.noDocumentDirectory
        }
        
        let fileURL = dir.appendingPathComponent(file)
        
        let text = try String(contentsOf: fileURL, encoding: .utf8)
        guard let data = text.data(using: .utf8) else {
            throw FileCacheError.invalidJson
        }
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String: Any]] else {
            throw FileCacheError.invalidJson
        }
        
        items = jsonArray.compactMap {
            TodoItem.parse(json: $0)
        }
    }
}


// MARK: - Private extension

private extension FileCache {

    func convertObjectsIntoString() -> String {
        let objects = items.map {
            $0.jsonString
        }

        let pairs = objects.joined(separator: ",")
        return "[\(pairs)]"
    }
}
