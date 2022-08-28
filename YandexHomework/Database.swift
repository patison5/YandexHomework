//
//  Database.swift
//  YandexHomework
//
//  Created by Fedor Penin on 25.08.2022.
//

import Foundation
import SQLite

enum DatabaseError: Error {
    case connectionFaild
    case errorParsingData
    case unknownedError
}

final class Database {

    // MARK: - Public properties

    static let shared = Database()

    var connection: Connection?

    // MARK: - Private properties

    private let name = "yandexDB"

    // MARK: - Init

    private init() {
        let path = getPath()
        if FileManager.default.fileExists(atPath: path) {
            makeConnection(with: path)
        } else {
            createFile(with: path)
            makeConnection(with: path)
            initTables()
        }
    }

    // MARK: - Private properties

    private func makeConnection(with path: String) {
        do {
            connection = try Connection(path)
        } catch {
            print(error)
        }
    }

    private func createFile(with path: String) {
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
    }

    private func getPath() -> String {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentDirectory[0].appendingPathComponent(name).appendingPathExtension("sqlite3")
        return url.path
    }

    private func initTables() {
        let tableName = "Todos"
        let id = Expression<String>("id")
        let text = Expression<String>("text")
        let importancy = Expression<String>("importancy")
        let deadline = Expression<Date?>("deadline")
        let isFinished = Expression<Bool>("is_finished")
        let createdAt = Expression<Date>("created_at")
        let changedAt = Expression<Date?>("changed_at")

        let todos = Table(tableName)
        do {
            try connection?.run(todos.create(ifNotExists: true) { table in
                table.column(id)
                table.column(text)
                table.column(importancy)
                table.column(deadline)
                table.column(isFinished)
                table.column(createdAt)
                table.column(changedAt)
            })
        } catch {
            print(error)
        }
    }
}
