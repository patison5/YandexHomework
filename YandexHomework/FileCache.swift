//
//  FileCache.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import Foundation
import CocoaLumberjack

final class FileCache {

    // MARK: - FileCacheServiceProtocol

    var items: [TodoItem] = []

    // MARK: - Private Properties

    private let fileName: String

    private let timerTime = 3.0

    // MARK: - Queues

    private let globalQueue = DispatchQueue(label: "filecacheQueue", attributes: .concurrent)
    private let mainQueue = DispatchQueue.main

    // MARK: - Init

    init(fileName: String) {
        self.fileName = fileName
    }
}

// MARK: - FileCacheServiceProtocol

extension FileCache: FileCacheServiceProtocol {

    func get(by id: String) -> TodoItem? {
        return items.first(where: { $0.id == id })
    }

    func change(item: TodoItem) throws {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items.remove(at: index)
        items.insert(item, at: index)
    }

    func add(item: TodoItem) throws {
        if items.first(where: { $0.id == item.id }) != nil {
            throw FileCacheError.itemAlreadyExist
        }

        items.append(item)
    }

    func removeItem(by id: String) throws {
        items.removeAll { item in
            return item.id == id
        }
    }

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        globalQueue.async {
            self.saveItems(to: file, completion: completion)
        }
    }

    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        globalQueue.async(flags: .barrier) {
            self.loadItems(from: file, completion: completion)
        }
    }
}

// MARK: - Private extension

private extension FileCache {

    func convertObjectsIntoString() -> String {
        let objects: [String] = items.map {
            $0.jsonString
        }

        let pairs = objects.joined(separator: ",")
        return "[\(pairs)]"
    }

    func saveItems(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var result: Result<Void, Error> = .failure(FileCacheError.undefined)
        defer { completion(result) }
        do {
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw FileCacheError.noDocumentDirectory
            }
            let pathWithFilename = documentDirectory.appendingPathComponent(file)
            let jsonString = self.convertObjectsIntoString()
            try jsonString.write(to: pathWithFilename, atomically: true, encoding: .utf8)
            result = .success(())
        } catch {
            result = .failure(error)
        }
    }

    func loadItems(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        var result: Result<[TodoItem], Error> = .failure(FileCacheError.undefined)
        defer { completion(result) }
        do {
            guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw FileCacheError.noDocumentDirectory
            }

            let fileURL = dir.appendingPathComponent(file)
            print(fileURL)

            let text = try String(contentsOf: fileURL, encoding: .utf8)
            guard let data = text.data(using: .utf8) else {
                throw FileCacheError.invalidJson
            }

            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                throw FileCacheError.invalidJson
            }
            let items = jsonArray.compactMap {
                TodoItem.parse(json: $0)
            }
            self.items = items
            result = .success(items)
        } catch {
            result = .failure(error)
        }
    }
}
