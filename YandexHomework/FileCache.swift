//
//  FileCache.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import Foundation
import SQLite

final class FileCache {

    // MARK: - Private Properties

    private let fileName: String

    private let tableName = "Todos"
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importancy = Expression<String>("importancy")
    private let deadline = Expression<Date?>("deadline")
    private let isFinished = Expression<Bool>("is_finished")
    private let createdAt = Expression<Date>("created_at")
    private let changedAt = Expression<Date?>("changed_at")

    private lazy var table = Table(tableName)

    // MARK: - Init

    init(fileName: String) {
        self.fileName = fileName
    }
}

// MARK: - FileCacheProtocol

extension FileCache: FileCacheProtocol {

    func change(item: TodoItem) throws {
        let dbItem = table.filter(id == item.id)
        try Database.shared.connection?.run(dbItem.update(
            text <- item.text,
            importancy <- item.importancy.rawValue,
            deadline <- item.deadline,
            isFinished <- item.isFinished,
            createdAt <- item.createdAt,
            changedAt <- item.changedAt
        ))
    }

    func add(item: TodoItem) throws {
        try insert(item: item)
    }

    func add(items: [TodoItem]) throws {
        try inser(items: items)
    }

    func remove(by id: String) throws {
        let item = table.filter(self.id == id)
        try Database.shared.connection?.run(item.delete())
    }

    func load() throws -> [TodoItem] {
        guard let db = Database.shared.connection else { throw DatabaseError.connectionFaild }
        let items = try db.prepare(table)
        return items.map {
            TodoItem(
                id: $0[id],
                text: $0[text],
                importancy: Importancy(rawValue: $0[importancy]) ?? .normal,
                deadline: $0[deadline],
                isFinished: $0[isFinished],
                createdAt: $0[createdAt],
                changedAt: $0[changedAt]
            )
        }
    }

    func dropTable() throws {
        try Database.shared.connection?.run(table.delete())
    }
}

// MARK: - Private extension

private extension FileCache {

    func insert(item: TodoItem) throws {
        let insert = table.insert(
            id <- item.id,
            text <- item.text,
            importancy <- item.importancy.rawValue,
            deadline <- item.deadline,
            isFinished <- item.isFinished,
            createdAt <- item.createdAt,
            changedAt <- item.changedAt
        )
        _ = try Database.shared.connection?.run(insert)
    }

    func inser(items: [TodoItem]) throws {
        _ = try Database.shared.connection?.run(table.insertMany(
            or: .fail,
            items.map {
                [
                    id <- $0.id,
                    text <- $0.text,
                    importancy <- $0.importancy.rawValue,
                    deadline <- $0.deadline,
                    isFinished <- $0.isFinished,
                    createdAt <- $0.createdAt,
                    changedAt <- $0.changedAt
                ]
            }
        ))
    }
}
