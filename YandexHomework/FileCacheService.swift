//
//  FileCacheService.swift
//  YandexHomework
//
//  Created by Fedor Penin on 28.08.2022.
//

import Foundation

final class FileCacheService {

    // MARK: - Private properties

    private let fileName: String

    private lazy var fileCache: FileCacheProtocol = FileCache(fileName: fileName)

    // MARK: - Queues

    private let globalQueue = DispatchQueue(label: "filecacheQueue", attributes: .concurrent)

    init(fileName: String = "develop.json") {
        self.fileName = fileName
    }
}

extension FileCacheService: FileCacheServiceProtocol {

    func change(item: TodoItem) throws {
        try fileCache.change(item: item)
    }

    func add(item: TodoItem) throws {
        try fileCache.add(item: item)
    }

    func remove(by id: String) throws {
        try fileCache.remove(by: id)
    }

    func patch(by items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void) {
        globalQueue.async(flags: .barrier) { [weak self] in
            var result: Result<Void, Error> = .failure(FileCacheError.undefined)
            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            do {
                try self?.fileCache.dropTable()
                try self?.fileCache.add(items: items)
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }

    func load(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        globalQueue.async(flags: .barrier) { [weak self] in
            var result: Result<[TodoItem], Error> = .failure(FileCacheError.undefined)
            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            do {
                guard let items = try self?.fileCache.load() else {
                    throw FileCacheError.undefined
                }
                result = .success(items)
            } catch {
                result = .failure(error)
            }
        }
    }
}
