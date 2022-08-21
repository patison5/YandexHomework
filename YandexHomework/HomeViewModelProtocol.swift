//
//  HomeViewModelProtocol.swift
//  YandexHomework
//
//  Created by Fedor Penin on 04.08.2022.
//

import Foundation

/// Описание вью-модели
protocol HomeViewModelProtocol: AnyObject {


    // MARK: - Public properties

    /// Указатель на родительский контроллер
    var view: HomeViewControllerProtocol? { get set }

    /// Набор задач
    var data: [TodoViewModel] { get set }


    // MARK: - Public methods

    /// Загрузить данные
    func viewDidLoad()

    /// Создать новую задачу на основе текста
    /// - Parameter text: Текст заголовка задачи
    func createTask(with text: String)

    /// Удалить задачу
    /// - Parameter indexPath: Позиция задачи в таблице
    func delete(at indexPath: IndexPath)

    /// Переключить состояние задачи (выполнено/не выполнено)
    /// - Parameters:
    ///   - model: Модель задачи
    ///   - at: Позиция задачи в таблице
    func toggleStatus(on model: TodoViewModel, at: IndexPath)

    /// Открыть модальное окно
    /// - Parameter model: Модель с задачей
    func openModal(with model: TodoViewModel?)

    /// Скрыть/Отобразить выполненные таски
    func toggleCompletedTasks()

    // Настроить шапку
    func setupHeader()
}
