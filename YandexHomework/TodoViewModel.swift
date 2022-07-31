//
//  TodoViewModel.swift
//  YandexHomework
//
//  Created by Fedor Penin on 31.07.2022.
//

import Foundation

final class TodoViewModel {


    // MARK: - Public properties

    weak var view: TodoModalViewController?


    // MARK: - Private properties

    private let fileName = "TodoModelSingle.json"

    private lazy var fileCache: FileCacheProtocol = FileCache(fileName: fileName)


    // MARK: - private properties

    private var id: String = UUID().uuidString

    private var text: String = "А потом вкусно позавтракать" {
        didSet { view?.set(text: text) }
    }

    private var importancy: Importancy = .normal {
        didSet { view?.set(importancy: importancy) }
    }

    private var deadline: Date? {
        didSet { view?.set(deadline: deadline) }
    }

    private var isFinished: Bool = false

    private var startDate: Date = Date()

    private var changedAt: Date?
}


// MARK: - TodoViewModelProtocol

extension TodoViewModel: TodoViewModelProtocol {

    func deleteButtonDidTap() {
        try? fileCache.removeItem(by: id)
        try? fileCache.saveItems(to: fileName)
        view?.dismiss(animated: true)
    }

    func importancyDidChange(importancy: Importancy) {
        self.importancy = importancy
        view?.isSaveButtonEnabled = true
    }

    func viewDidLoad() {
        getData()
    }

    func deadlineDidChange(isEnabled: Bool) {
        if isEnabled {
            self.deadline = deadline ?? Date().dayAfter
            view?.showCalendar()
        } else {
            self.deadline = nil
            view?.dismissCalendar()
        }
        view?.isSaveButtonEnabled = true
    }

    func deadLineDidClick() {
        self.deadline = deadline ?? Date().dayAfter
        view?.showCalendar()
        view?.isSaveButtonEnabled = true
    }

    func textDidChange(text: String) {
        self.text = text
        view?.isSaveButtonEnabled = true
    }

    func datePickerChanged(date: Date) {
        self.deadline = date
        view?.isSaveButtonEnabled = true
    }

    func saveButtonDidTap() {
        saveData()
        view?.dismiss(animated: true)
    }
}


// MARK: - Private methods

private extension TodoViewModel {

    private func saveData() {
        let newItem: TodoItem = TodoItem(id: id, text: text, importancy: importancy, deadline: deadline, isFinished: isFinished, createdAt: startDate, changedAt: changedAt)

        try? fileCache.change(item: newItem)
        try? fileCache.saveItems(to: fileName)
    }

    func getData() {
        try? fileCache.loadItems(from: fileName)

        let todo: TodoItem? = fileCache.get(by: "TodoItemModal")
        id = todo?.id ?? "TodoItemModal"
        text = todo?.text ?? text
        importancy = todo?.importancy ?? importancy
        deadline = todo?.deadline
        isFinished = todo?.isFinished ?? isFinished
        startDate = todo?.createdAt ?? startDate
        changedAt = todo?.changedAt

        saveData()
    }
}
