//
//  TodoItemTests.swift
//  HomeworkTests
//
//  Created by Fedor Penin on 27.07.2022.
//

import XCTest
@testable import YandexHomework

class TodoItemTests: XCTestCase {

    var todoItem: TodoItem!

    override func setUp() {
        super.setUp()
        todoItem = TodoItem(
            id: "Todo1",
            text: "Todo1 text",
            importancy: .important,
            deadline: Date(),
            isFinished: false,
            createdAt: Date(),
            changedAt: Date()
        )
    }

    override func tearDown() {
        todoItem = nil
        super.tearDown()
    }

    func testJsonParsing() throws {
        let json: [String: Any] = [
            "id": "TodoTest",
            "text": "TodoTest",
            "importancy": "important",
            "deadline": 1658917535.767741,
            "createdAt": 1658917535.767741,
            "isFinished": true
        ]

        guard let parsedItem = TodoItem.parse(json: json) else {
            XCTFail("Не удалось распарсить json в объект")
            return
        }

        XCTAssertEqual(parsedItem.id, "TodoTest", "преобразование ID задачи")
        XCTAssertEqual(parsedItem.text, "TodoTest", "преобразование текста задачи")
        XCTAssertEqual(parsedItem.importancy, Importancy.important, "преобразование важности задачи")
        XCTAssertEqual(parsedItem.deadline, Date(timeIntervalSince1970: 1658917535.767741), "преобразование времени дедлайна задачи")
        XCTAssertEqual(parsedItem.isFinished, true, "преобразование статуса завершения задачи")
        XCTAssertEqual(
            parsedItem.createdAt,
            Date(timeIntervalSince1970: 1658917535.767741),
            "преобразование времени старта выполнения задачи"
        )
    }

    func testGettingJsonPerformance() throws {
        self.measure {
            _ = todoItem.json
        }
    }
}
