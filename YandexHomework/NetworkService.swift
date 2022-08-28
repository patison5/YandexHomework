//
//  NetworkService.swift
//  YandexHomework
//
//  Created by Fedor Penin on 12.08.2022.
//

import Foundation
import GameplayKit

// MARK: - NetworkServiceProtocol

final class NetworkService: NetworkServiceProtocol {

    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {}
    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {}
    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {}

    func patch(with list: ApiTodoListModel, completion: @escaping (Result<ApiTodoListModel, Error>) -> Void) {
        Task {
            do {
                let result = try await ecsponentialRetry(action: { () -> ApiTodoListModel in
                    let patchedList = try await patch(with: list)
                    if Variables.shared.isDirty { Variables.shared.isDirty = false }
                    return patchedList
                })
                completion(.success(result))
            } catch {
                self.patch(with: list, completion: completion)
                completion(.failure(error))
                Variables.shared.isDirty = true
            }

        }
    }

    func get(completion: @escaping (Result<ApiTodoListModel, Error>) -> Void) {
        Task {
            do {
                let result = try await ecsponentialRetry(action: { () -> ApiTodoListModel in
                    let result = try await getItems()
                    return result
                })
                completion(.success(result))
            } catch {
                completion(.failure(error))
                Variables.shared.isDirty = true
            }
        }
    }

    func delete(by id: String, completion: @escaping (Result<ApiTodoElementModel, Error>) -> Void) {
        Task {
            do {
                let result = try await ecsponentialRetry(action: { () -> ApiTodoElementModel in
                    let result = try await delete(by: id)
                    return result
                })
                completion(.success(result))
            } catch {
                completion(.failure(error))
                Variables.shared.isDirty = true
            }
        }
    }

    func update(by element: ApiTodoElementModel, completion: @escaping (Result<ApiTodoElementModel, Error>) -> Void) {
        Task {
            do {
                let result = try await ecsponentialRetry(action: { () -> ApiTodoElementModel in
                    let result = try await update(by: element)
                    return result
                })
                completion(.success(result))
            } catch {
                completion(.failure(error))
                Variables.shared.isDirty = true
            }
        }
    }

    func add(by element: ApiTodoElementModel, completion: @escaping (Result<ApiTodoElementModel, Error>) -> Void) {
        Task {
            do {
                let result = try await ecsponentialRetry(action: { () -> ApiTodoElementModel in
                    let result = try await add(new: element)
                    return result
                })
                completion(.success(result))
            } catch {
                completion(.failure(error))
                Variables.shared.isDirty = true
            }
        }
    }
}

// MARK: - Private methods

private extension NetworkService {

    /// Отправить запрос
    /// - Parameters:
    ///   - method: Тип запроса
    ///   - url: Путь запроса
    ///   - body: Тело запроса
    /// - Returns: Результат ответа сервера
    func sendRequest<T: Decodable>(
        method: String,
        url: String,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: url) else {
            throw ApiError.wrongRequest
        }
        let authName = Variables.shared.isOAuth ? "OAuth" : "Bearer"
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30.0
        request.allHTTPHeaderFields = [
            "Authorization": "\(authName) \(Variables.shared.token)",
            "X-Last-Known-Revision": "\(Variables.shared.revision)"
        ]
        if let body = body {
            request.httpBody = body
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse, let error = assert(response: response) {
            throw error
        }
        let model = try JSONDecoder().decode(T.self, from: data)
        return model
    }

    /// Выполнить метод с экспонентной частотой повторения до тех пор
    /// пока либо метод не завершиться успешно, либо не выйдет за лимит времени ожидания
    /// - Parameters:
    ///   - startDelay: Стартовая задержка
    ///   - factor: Фактор умножения
    ///   - maxDelay: Лимит времени попыток (точка остановки повторения запросов)
    ///   - jitter: Джиттер
    ///   - action: Необходимый запрос
    /// - Returns: Результат ответа сервера
    func ecsponentialRetry<T>(
        startDelay: Double = 2,
        factor: Double = 1.5,
        maxDelay: Double = 120,
        jitter: Double = 0.05,
        action: (() async throws -> T)
    ) async throws -> T {
        var delay: Double = startDelay
        while delay < maxDelay {
            let rand = Double.random(in: 0.01...jitter)
            delay = min(delay * (factor + rand), maxDelay)
            do {
                return try await action()
            } catch {
                if let error = error as? ApiError { // осталось понять, что будет с patch ...
                    if error == .wrongRequest {
                        throw error
                    }
                }
                sleep(UInt32(delay))
                continue
            }
        }
        return try await action()
    }

    /// Проверить ошибку ответа сервера
    /// - Parameter response: Ответ сервера
    /// - Returns: Именнованная ошибка
    func assert(response: HTTPURLResponse) -> Error? {
        switch response.statusCode {
        case 400:
            return ApiError.wrongRequest
        case 401:
            return ApiError.error401
        case 404:
            return ApiError.suchIdDoesntExist
        case 500:
            return ApiError.error500
        default:
            return nil
        }
    }

    func getItems() async throws -> ApiTodoListModel {
        return try await sendRequest(
            method: "GET",
            url: "https://beta.mrdekk.ru/todobackend/list"
        )
    }

    func patch(with list: ApiTodoListModel) async throws -> ApiTodoListModel {
        let body = try JSONEncoder().encode(list)
        return try await sendRequest(
            method: "PATCH",
            url: "https://beta.mrdekk.ru/todobackend/list",
            body: body
        )
    }

    func delete(by id: String) async throws -> ApiTodoElementModel {
        return try await sendRequest(
            method: "DELETE",
            url: "https://beta.mrdekk.ru/todobackend/list/\(id)"
        )
    }

    func update(by element: ApiTodoElementModel) async throws -> ApiTodoElementModel {
        let body = try JSONEncoder().encode(element)
        let id = element.element.id
        return try await sendRequest(
            method: "PUT",
            url: "https://beta.mrdekk.ru/todobackend/list/\(id)",
            body: body
        )
    }

    func add(new element: ApiTodoElementModel) async throws -> ApiTodoElementModel {
        let body = try JSONEncoder().encode(element)
        return try await sendRequest(
            method: "POST",
            url: "https://beta.mrdekk.ru/todobackend/list/",
            body: body
        )
    }

    //    Пока оставллю тут, попытка сделать через рекурсию и asyncAfter...
    //    func ecsponentialRetry(
    //        delay: Double = 2,
    //        factor: Double = 1.5,
    //        maxDelay: Double = 120,
    //        jitter: Double = 0.05,
    //        action: @escaping (() -> Void),
    //        completion: (() -> Void)
    //    ) {
    //        action()
    //        let delay = min(delay * factor, maxDelay)
    //        if delay == maxDelay {
    //            return
    //        }
    //        print(delay)
    //        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
    //            self?.ecsponentialRetry(delay: delay, action: action, completion: completion)
    //        }
    //    }
}
