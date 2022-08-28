//
//  MockNetworkService.swift
//  YandexHomework
//
//  Created by Fedor Penin on 12.08.2022.
//

import Foundation

final class MockNetworkService: NetworkServiceProtocol {

    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            if Bool.random() {
                completion(.success(self.getStartArray()))
            } else {
                completion(.failure(NetworkError.undefined))
            }
        }
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
          completion(.success(item))
        }
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
          completion(.success(TodoItem(text: "Hello world")))
        }
    }
}

private extension MockNetworkService {

    func getStartArray() -> [TodoItem] {
        return [
            TodoItem(
                text: "Отдохнуть от проги🙄",
                importancy: .important,
                deadline: Date(timeIntervalSince1970: 1658917535.767741),
                isFinished: false
            ),
            TodoItem(
                text: "Сгонять в бар, купить пивка, рыбки, крекеров и всего того, что может спасти наши бренные души от бытия насущного...",
                importancy: .important,
                deadline: nil,
                changedAt: Date(timeIntervalSince1970: 1658917535.767741)
            ),
            TodoItem(
                text: "Бросить все и умчать в закат куда-нить в Грузию. ",
                importancy: .important,
                deadline: Date(timeIntervalSince1970: 1658917535.767741),
                isFinished: true
            ),
            TodoItem(
                text: "не забыть все-таки покушать🙄🙄🙄",
                importancy: .normal,
                deadline: Date(timeIntervalSince1970: 1658917535.767741),
                isFinished: true
            ),
            TodoItem(
                text: "Сделать экран редактирования заметки. обработка показа/скрытия клавиатуры (фрейм клавиатуры может быть обработка поворотов (в том числе с активной клавиатурой) соблюдайте направление данных",
                importancy: .normal,
                deadline: nil,
                changedAt: Date(timeIntervalSince1970: 1658917535.767741)
            ),
            TodoItem(
                text: "сделать экран со списком заметок. включая удаление заметок, отметку “выполнено”, etc обратите внимание на направление оповещений; отображение должно быть синхронизовано с моделью рекомендуется использовать navigation controller large titles",
                importancy: .important,
                createdAt: Date(timeIntervalSince1970: 1658917535.767741),
                changedAt: Date(timeIntervalSince1970: 1658917535.767741)
            ),
            TodoItem(
                text: "Выпить пива",
                importancy: .unImportant,
                deadline: nil,
                isFinished: false
            ),
            TodoItem(
                text: "Смотри предыдущий пункт",
                importancy: .normal,
                deadline: nil,
                isFinished: false
            ),
            TodoItem(
                text: "Не хватило, над повторить",
                importancy: .normal,
                deadline: nil,
                isFinished: false
            ),
            TodoItem(
                text: "Пожалуй, можно и по пиву",
                importancy: .normal,
                deadline: Date(timeIntervalSince1970: 1658917535.767741),
                isFinished: false
            ),
            TodoItem(
                text: "Смотри предыдущий пункт",
                importancy: .normal,
                deadline: nil,
                isFinished: false
            ),
            TodoItem(
                text: "Не хватило, над повторить",
                importancy: .normal,
                deadline: nil,
                isFinished: true
            ),
            TodoItem(
                text: "Пожалуй, можно и по пиву",
                importancy: .normal,
                deadline: Date(timeIntervalSince1970: 1658917535.767741),
                isFinished: false
            )
        ]
    }
}
