//
//  TodoViewModelProtocol.swift
//  YandexHomework
//
//  Created by Fedor Penin on 31.07.2022.
//

import UIKit

protocol TodoViewModelProtocol {

    /// ViewDidLoad
    func viewDidLoad()

    /// Отследить состояние  switch-кнопки
    /// - Parameter isEnabled: Состояние
    func deadlineDidChange(isEnabled: Bool)

    /// Кликнуть по лейблу с дедлайном
    func deadLineDidClick()

    /// Отследить изменение текста
    /// - Parameter text: Новый текст
    func textDidChange(text: String)

    /// Отследить изменение состояния светчера важности
    /// - Parameter importancy: Новое значение важности задачи
    func importancyDidChange(importancy: Importancy)

    /// Отследить состояние выбора даты
    /// - Parameter date: Новая дата
    func datePickerChanged(date: Date)

    /// Отследить нажание на кнопку "сохранить"
    func saveButtonDidTap()

    /// Отследить нажатие на кнопку "удалить"
    func deleteButtonDidTap()
}
