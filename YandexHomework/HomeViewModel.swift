//
//  HomeViewModel.swift
//  YandexHomework
//
//  Created by Fedor Penin on 04.08.2022.
//

import UIKit

final class HomeViewModel {

    // MARK: - Public properties

    weak var view: HomeViewControllerProtocol?

    var data: [TodoViewModel] = [] {
        didSet {
            setupHeader()
        }
    }

    // MARK: - private properties

    private var isHidden = true

    private let fileName = "development.json"

    private lazy var fileCache: FileCacheProtocol = FileCache(fileName: fileName)
}

// MARK: - HomeViewModelDelegate

extension HomeViewModel: HomeViewModelDelegate {

    func didUpdate(model: TodoViewModel, state: TodoViewState) {
        let newItem = TodoItem(
            id: model.item.id,
            text: state.text,
            importancy: state.importancy,
            deadline: state.deadline,
            isFinished: state.isFinished,
            createdAt: state.createdAt,
            changedAt: state.changedAt
        )

        let isExist = data.contains { $0.item.id == newItem.id  }
        if isExist {
            try? fileCache.change(item: newItem)
        } else {
            data.append(model)
            try? fileCache.add(item: newItem)
        }

        try? fileCache.saveItems(to: fileName)
        view?.items = data
        view?.reloadData()
    }

    func didDelete(model: TodoViewModel) {
        try? fileCache.removeItem(by: model.item.id)
        try? fileCache.saveItems(to: fileName)
        data.removeAll { $0.item.id == model.item.id }
        view?.items = data
        view?.reloadData()
    }
}

// MARK: - HomeViewModelProtocol

extension HomeViewModel: HomeViewModelProtocol {

    func createTask(with text: String) {
        let newModel = TodoViewModel(item: TodoItem(text: text))
        data.append(newModel)
        try? fileCache.add(item: newModel.item)
        try? fileCache.saveItems(to: fileName)
        view?.items = data
        view?.insertRow(at: IndexPath(row: data.count - 1, section: 0))
    }

    func toggleCompletedTasks() {
        let sorted = data.filter { !$0.item.isFinished  }
        let cleaned = data.enumerated().compactMap { $0.element.item.isFinished ? $0.offset : nil }
        let indices = cleaned.compactMap { IndexPath(row: $0, section: 0) }

        if isHidden {
            view?.items = sorted
            view?.deleteRows(at: indices)
        } else {
            view?.items = data
            view?.insertRows(at: indices)
        }
        isHidden.toggle()
        setupHeader()
    }

    func openModal(with model: TodoViewModel? = nil) {
        guard let model = model else {
            let newModel = TodoViewModel(item: TodoItem(text: ""))
            newModel.delegate = self
            let controller = TodoModalViewController(viewModel: newModel)
            newModel.modal = controller
            let navigationController = UINavigationController(rootViewController: controller)
            view?.present(modal: navigationController)
            return
        }

        let controller = TodoModalViewController(viewModel: model)
        model.modal = controller
        let navigationController = UINavigationController(rootViewController: controller)
        view?.present(modal: navigationController)
    }

    func viewDidLoad() {
        fetchItems()
    }

    func fetchItems() {
        try? fileCache.loadItems(from: fileName)

        // Временная фигня для дебага
        if fileCache.items.isEmpty {
            let startArray = getStartArray()
            startArray.forEach {
                try? fileCache.add(item: $0)
            }
            try? fileCache.saveItems(to: fileName)
        }

        data = fileCache.items.map { TodoViewModel(item: $0) }
        data.forEach {
            $0.delegate = self
        }
        view?.items = data
    }

    func delete(at indexPath: IndexPath) {
        guard let view = view else { return }
        let id = view.items[indexPath.row].item.id
        if !isHidden {
            try? fileCache.removeItem(by: id)
            try? fileCache.saveItems(to: fileName)
            data.removeAll { $0.item.id == id }
            view.items.remove(at: indexPath.row)
            view.deleteRow(at: indexPath)
        } else {
            try? fileCache.removeItem(by: data[indexPath.row].item.id)
            try? fileCache.saveItems(to: fileName)
            data.remove(at: indexPath.row)
            view.items = data
            view.deleteRow(at: indexPath)
        }
        setupHeader()
    }

    func toggleStatus(on model: TodoViewModel, at: IndexPath) {
        guard let view = view else { return }
        if !isHidden {
            model.state.isFinished.toggle()
            model.item = model.item.toggleComplete()
            try? fileCache.change(item: model.item)
            try? fileCache.saveItems(to: fileName)
            view.items.remove(at: at.row)
            view.deleteRow(at: at)
        } else {
            model.state.isFinished.toggle()
            model.item = model.item.toggleComplete()
            try? fileCache.change(item: model.item)
            try? fileCache.saveItems(to: fileName)
            view.reloadRow(at: at)
        }
        setupHeader()
    }

    func setupHeader() {
        let filtered = data.filter { $0.item.isFinished  }
        let amount = filtered.count
        view?.setupHeader(title: isHidden ? "Показать" : "Скрыть", amount: amount)
    }
}

// MARK: - Private methods

private extension HomeViewModel {

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
                text: "добавить навигацию между экранами с использованием механизма modal presentation. экран редактирования должен быть достаточно универсальным, чтобы обрабатывать как создание новых заметок, так и редактирование существующих",
                importancy: .unImportant,
                createdAt: Date(timeIntervalSince1970: 1658917535.767741),
                changedAt: Date(timeIntervalSince1970: 1658917535.767741)
            ),
            TodoItem(
                text: "поддержать повороты экрана на редактировании записи. в landscape поле ввода должно занимать весь экран, остальные контролы нужно прятать",
                importancy: .normal,
                deadline: nil,
                isFinished: true,
                changedAt: Date(timeIntervalSince1970: 1658917535.767741)
            ),
            TodoItem(
                text: "custom transition на экран редактирования анимировать появление именно из той ячейки table view, с которой взаимодействовал пользователь",
                importancy: .normal,
                deadline: nil,
                changedAt: Date(timeIntervalSince1970: 1658917535.767741)
            ),
            TodoItem(
                text: "поддержать механизм preview \ntableView(_:contextMenuConfigurationForRowAt:point:)\n tableView(_:willPerformPreviewActionForMenuWith:animator:)",
                importancy: .unImportant,
                deadline: Date(timeIntervalSince1970: 1658917535.767741),
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
