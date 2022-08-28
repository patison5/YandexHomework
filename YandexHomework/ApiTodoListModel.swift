//
//  ApiTodoListModel.swift
//  YandexHomework
//
//  Created by Fedor Penin on 17.08.2022.
//

import UIKit

struct ApiTodoElementModel: Codable {
    let element: ApiTodoItem
    let revision: Int
    let status: String
}

struct ApiTodoListModel: Codable {
    let list: [ApiTodoItem]
    let revision: Int
    let status: String
}

struct ApiTodoItem: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Date?
    let isFinished: Bool
    let createdAt: Date
    let changedAt: Date
    let lastUpdatedBy: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let deadline = deadline?.timeIntervalSince1970 {
            try container.encode(Int(deadline), forKey: .deadline)
        }
        try container.encode(Int(createdAt.timeIntervalSince1970), forKey: .createdAt)
        try container.encode(Int(changedAt.timeIntervalSince1970), forKey: .changedAt)

        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importance, forKey: .importance)
        try container.encode(isFinished, forKey: .isFinished)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case text = "text"
        case importance = "importance"
        case deadline = "deadline"
        case isFinished = "done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

extension ApiTodoItem {

    static func parse(from item: TodoViewModel) -> ApiTodoItem? {
        let todoItem = item.item
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "12345678-1F21-4D46-B817-0D6A52709EA6"
        return ApiTodoItem(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importancy.rawValue,
            deadline: todoItem.deadline,
            isFinished: todoItem.isFinished,
            createdAt: todoItem.createdAt,
            changedAt: todoItem.changedAt ?? todoItem.createdAt,
            lastUpdatedBy: deviceID
        )
    }
}
