//
//  TodoViewModel.swift
//  YandexHomework
//
//  Created by Fedor Penin on 31.07.2022.
//

import Foundation

//protocol TodoCellProtocol: AnyObject {
//
//    func configure(with state: TodoViewState)
//}

protocol TodoModalProtocol: AnyObject {

    /// Настроить отображение модального окна
    /// - Parameter state: Задача
    func configure(with state: TodoViewState)

    /// Закрыть модальное окно
    /// - Parameter animated: Необходимость в анимации
    func closeModal(animated: Bool)

    /// Показать календарь
    func showCalendar()

    /// Спраятать календарь
    func dismissCalendar()

    /// Установить дедлайн
    /// - Parameter date: Дата
    func setupDeadline(with date: Date)
}

final class TodoViewModel {

    // MARK: - Public properties

    //    weak var cell: TodoCellProtocol?

    weak var modal: TodoModalProtocol?

    weak var delegate: HomeViewModelDelegate?

    var item: TodoItem

    lazy var state = TodoViewState(item: item) {
        didSet {
            modal?.configure(with: state)
        }
    }


    // MARK: - private properties


    // MARK: - Init

    init(item: TodoItem) {
        self.item = item
    }
}


// MARK: - TodoViewModelProtocol

extension TodoViewModel: TodoViewModelProtocol {

    func deadlineDidChange(isEnabled: Bool) {
        state.deadline = isEnabled ? state.deadline ?? Date().dayAfter : nil
        isEnabled ? modal?.showCalendar() : modal?.dismissCalendar()
    }

    func deadLineDidClick() {
        modal?.setupDeadline(with: state.deadline ?? Date().dayAfter)
        modal?.showCalendar()
    }

    func textDidChange(text: String) {
        state.text = text
    }

    func importancyDidChange(importancy: Importancy) {
        state.importancy = importancy
    }

    func datePickerChanged(date: Date) {
        state.deadline = date
    }

    func saveButtonDidTap() {
        modal?.closeModal(animated: true)
        delegate?.didUpdate(model: self, state: state)
    }

    func deleteButtonDidTap() {
        modal?.closeModal(animated: true)
        delegate?.didDelete(model: self)
    }
}
