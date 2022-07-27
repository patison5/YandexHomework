//
//  TodoItem.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

// TodoItem, parsing JSON
//
// Расширение для структуры TodoItem
// Содержит функцию (static func parse(json: Any) -> TodoItem?) для разбора JSON
// Содержит вычислимое свойство (var json: Any) для формирования JSON
// Не сохранять в JSON важность, если она "обычная"
// Не сохранять в JSON сложные объекты (Date)
// Сохранять deadline только если он задан
// Обязательно использовать JSONSerialization (т.е. работу со словарем)

import Foundation


/// Перечисление важности задачи
enum Importancy: String {
    case normal
    case important
    case unImportant
}


struct TodoItem: Equatable {
    
    
    // MARK: - Public properties
    
    /// Уникальный идентификатор
    var id: String = UUID().uuidString
    
    /// Содержание задачи
    let text: String
    
    /// Важность задачи
    var importancy: Importancy = .normal
    
    /// Дедлайн
    let deadline: Date?
    
    /// Статус завершения задачи
    var isFinished: Bool
    
    /// Дата начала выполнения задачи
    let startDate: Date
    
    /// Дата окончания задачи
    var finishDate: Date?
    
    /// Генерация json из объекта
    var json: Any {
        get {
            do {
                let data = try getData()
                return try JSONSerialization.jsonObject(with: data)
            } catch {
                assertionFailure("Ошибка сериализации")
                exit(1) //Это не хорошо... Лучше сделать метод throwable, а не св-во json...
            }
        }
    }
    
    var jsonString: String {
        let mirror = Mirror(reflecting: self)
        let pairs: [String] = mirror.children.compactMap { element in
            guard let label = element.label else { return nil }
            guard let value = getPairValue(by: element.value) else { return nil }
            return "\"\(label)\":\(value)"
        }
        let result = "{\(pairs.joined(separator: ","))}"
        return result
    }
    
    func getData() throws -> Data {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError()
        }
        return data
    }
    
    func getPairValue(by elementValue: Any) -> Any? {
        switch elementValue {
        case is String:
            return "\"\(elementValue)\""
        case let date as Date:
            return date.timeIntervalSince1970
        case let isFinished as Bool:
            return isFinished
        case let importancy as Importancy:
            return importancy == Importancy.normal ? nil : "\"\(importancy)\""
        default:
            return nil
        }
    }
}

extension TodoItem {
    
    /// Преобразовать json в объект TodoItem
    /// - Parameter json: Информация об объекте
    /// - Returns: Задача, если она может быть создана
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any] else { return nil }
        guard let id = json["id"] as? String,
              let text = json["text"] as? String,
              let isFinished = json["isFinished"] as? Bool,
              let startTimeInterval = json["startDate"] as? Double else { return nil }
        
        let startDate: Date = Date(timeIntervalSince1970: startTimeInterval)
        var importancy: Importancy = .normal
        var deadline: Date?
        var finishDate: Date?
        
        if let rawValue = json["importancy"] as? String, let value = Importancy(rawValue: rawValue) {
            importancy = value
        }
        
        if let deadlineTimeInterval = json["deadline"] as? Double {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        if let finishTimeInterval = json["finishDate"] as? Double {
            finishDate = Date(timeIntervalSince1970: finishTimeInterval)
        }
        
        return TodoItem(
            id: id,
            text: text,
            importancy: importancy,
            deadline: deadline,
            isFinished: isFinished,
            startDate: startDate,
            finishDate: finishDate
        )
    }
}
