//
//  ApiError.swift
//  YandexHomework
//
//  Created by Fedor Penin on 17.08.2022.
//

import Foundation

enum ApiError: String, Error {

    case incorrectEndpoint = "Неправильно указан путь до API сервиса"

    case connectionTimedOut = "Время ожидания вышло"

    case errorParsingJson = "Ошибка декодировки JSON"

    case suchIdDoesntExist = "Элемента с таким ID не найдено"

    case somethingGetWrong = "Что-то пошло не так"

    case wrongRequest = "Неправильный запрос"

    case error500 = "Ошибка сервера"

    case error401 = "Неверная авторизация"
}
