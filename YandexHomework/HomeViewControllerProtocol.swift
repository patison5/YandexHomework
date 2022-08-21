//
//  HomeViewControllerProtocol.swift
//  YandexHomework
//
//  Created by Fedor Penin on 05.08.2022.
//

import UIKit

protocol HomeViewControllerProtocol: AnyObject {

    var items: [TodoViewModel] { get set }

    /// Настроить шапку
    /// - Parameters:
    ///   - title: Название кнопки
    ///   - amount: Кол-во задач
    func setupHeader(title: String, amount: Int)

    /// Обновить всю ячейку
    func reloadData()

    /// Обновить секцию
    func reloadSection()

    /// Обновить ячейки в таблице
    /// - Parameter indexPathes: Позиции
    func reloadRows(at indexPathes: [IndexPath])

    /// Обновить ячэйку в таблице
    /// - Parameter indexPath: Позиция
    func reloadRow(at indexPath: IndexPath)

    /// Удалить ячейку из таблицы
    /// - Parameter indexPath: Позиция
    func deleteRow(at indexPath: IndexPath)

    /// Удалить набор ячеек из таблицы по набору индексов
    /// - Parameter indexPathes: Набор индексов
    func deleteRows(at indexPathes: [IndexPath])

    /// Добавить ячейку в таблицу
    /// - Parameter indexPath: Позиция
    func insertRow(at indexPath: IndexPath)

    /// Добавить набор ячеек в таблицу по набору индексов
    /// - Parameter indexPathes: Набор индексов
    func insertRows(at indexPathes: [IndexPath])

    /// Отрисовать модальное окно
    /// - Parameter modal: Контроллер модалки
    func present(modal: UINavigationController)
}
