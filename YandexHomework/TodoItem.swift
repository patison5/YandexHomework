//
//  TodoItem.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

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
    let id: String

    /// Содержание задачи
    let text: String

    /// Важность задачи
    let importancy: Importancy

    /// Дедлайн
    let deadline: Date?

    /// Статус завершения задачи
    let isFinished: Bool

    /// Дата начала выполнения задачи
    let createdAt: Date

    /// Дата окончания задачи
    let changedAt: Date?

    init(
        id: String = UUID().uuidString,
        text: String,
        importancy: Importancy = .normal,
        deadline: Date? = nil,
        isFinished: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importancy = importancy
        self.deadline = deadline
        self.isFinished = isFinished
        self.createdAt = createdAt
        self.changedAt = changedAt
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
              let startTimeInterval = json["createdAt"] as? Double else { return nil }

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
            createdAt: startDate,
            changedAt: finishDate
        )
    }

    /// Генерация json из объекта
    var json: Any {
        get {
            jsonString as Any
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
}


// MARK: - Private methods

private extension TodoItem {

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

    func getData() throws -> Data {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError()
        }
        return data
    }
}


// MARK: - Public methods

extension TodoItem {

  func toggleComplete() -> TodoItem {
      return TodoItem(
        id: self.id,
        text: self.text,
        importancy: self.importancy,
        deadline: self.deadline,
        isFinished: !self.isFinished,
        createdAt: self.createdAt,
        changedAt: self.createdAt
      )
  }
}
