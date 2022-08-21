//
//  FileCacheTests.swift
//  HomeworkTests
//
//  Created by Fedor Penin on 27.07.2022.
//

import XCTest
@testable import YandexHomework

class FileCacheTests: XCTestCase {

    private let fileName = "TodoListTest.json"
    private var cache: FileCache!

    var test1: TodoItem!
    var test2: TodoItem!

    override func setUp() {
        super.setUp()
        cache = FileCache(fileName: fileName)

        test1 = TodoItem(
            id: "Todo1",
            text: "Todo1 text",
            importancy: .normal,
            deadline: Date(timeIntervalSince1970: 1658917535.767741),
            isFinished: false,
            createdAt: Date(timeIntervalSince1970: 1658917535.767741),
            changedAt: Date(timeIntervalSince1970: 1658917535.767741)
        )

        test2 = TodoItem(
            id: "Todo2",
            text: "Todo2 text",
            importancy: .important,
            deadline: Date(timeIntervalSince1970: 1658917535.767741),
            isFinished: false,
            createdAt: Date(timeIntervalSince1970: 1658917535.767741),
            changedAt: Date(timeIntervalSince1970: 1658917535.767741)
        )
    }

    override func tearDown() {
        cache = nil
        super.tearDown()
    }

    func testAddItem() throws {
        // act
        try cache.add(item: test1)
        try cache.add(item: test2)

        // assert
        XCTAssertEqual(cache.items, [test1, test2])
    }

    func testRemovetem() throws {
        // act
        try cache.add(item: test1)
        try cache.add(item: test2)
        try cache.removeItem(by: test1.id)

        // assert
        XCTAssertEqual(cache.items, [test2])
    }
    
    func testReadWriteFiles() throws {
        // setup
        let cache2: FileCache = FileCache(fileName: fileName)

        // act
        try cache.add(item: test1)
        try cache.add(item: test2)
//        try cache2.loadItems(from: fileName)

        // assert
        XCTAssertEqual(cache.items, cache2.items)
    }

    func testAddPerfomance() throws {
        self.measure {
            try? cache.add(item: test1)
        }
    }

    func testRemovePerfomance() throws {
        try cache.add(item: test1)

        self.measure {
            try? cache.removeItem(by: test1.id)
        }
    }
}
