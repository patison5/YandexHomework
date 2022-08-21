//
//  HomeViewModel.swift
//  YandexHomework
//
//  Created by Fedor Penin on 04.08.2022.
//

import UIKit
import CocoaLumberjack

final class HomeViewModel {

    // MARK: - Public properties

    weak var view: HomeViewControllerProtocol?

    var data: [TodoViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.setupHeader()
            }
        }
    }

    // MARK: - private properties

    private var isHidden = true

    private let fileName = "development.json"

    private lazy var fileCache: FileCacheServiceProtocol = FileCache(fileName: fileName)

    private let mockNetwork: NetworkServiceProtocol = MockNetworkService()
}

// MARK: - HomeViewModelDelegate

extension HomeViewModel: HomeViewModelDelegate {

    func didUpdate(model: TodoViewModel, state: TodoViewState) {
        Task {
            do {
                _ = try await mockNetwork.editTodoItem(model.item)
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

                self.saveItems()
                view?.items = data
            } catch {
                DDLogError(error)
            }
        }
        view?.reloadData()
    }

    func didDelete(model: TodoViewModel) {
        try? fileCache.removeItem(by: model.item.id)
        self.saveItems()
        data.removeAll { $0.item.id == model.item.id }
        view?.items = data
        view?.reloadData()
    }
}

// MARK: - HomeViewModelProtocol

extension HomeViewModel: HomeViewModelProtocol {

    func viewDidLoad() {
        fetchItems()
    }

    func createTask(with text: String) {
        let newModel = TodoViewModel(item: TodoItem(text: text))
        data.append(newModel)
        try? fileCache.add(item: newModel.item)
        self.saveItems()
        view?.items = data
        view?.insertRow(at: IndexPath(row: data.count - 1, section: 0))
    }

    func delete(at indexPath: IndexPath) {
        guard let view = view else { return }
        let id = view.items[indexPath.row].item.id
        if !isHidden {
            Task {
                try await mockNetwork.deleteTodoItem(at: id)
            }
            try? fileCache.removeItem(by: id)
            self.saveItems()
            data.removeAll { $0.item.id == id }
            view.items.remove(at: indexPath.row)
            view.deleteRow(at: indexPath)
        } else {
            Task {
                try await mockNetwork.deleteTodoItem(at: data[indexPath.row].item.id)
            }
            try? fileCache.removeItem(by: data[indexPath.row].item.id)
            self.saveItems()
            data.remove(at: indexPath.row)
            view.items = data
            view.deleteRow(at: indexPath)
        }
        setupHeader()
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

    func toggleStatus(on model: TodoViewModel, at: IndexPath) {
        guard let view = view else { return }
        if !isHidden {
            Task {
                _ = try await mockNetwork.editTodoItem(model.item)
            }
            model.state.isFinished.toggle()
            model.item = model.item.toggleComplete()
            try? fileCache.change(item: model.item)
            self.saveItems()
            view.items.remove(at: at.row)
            view.deleteRow(at: at)
        } else {
            Task {
                _ = try await mockNetwork.editTodoItem(model.item)
            }
            model.state.isFinished.toggle()
            model.item = model.item.toggleComplete()
            try? fileCache.change(item: model.item)
            self.saveItems()
            view.reloadRow(at: at)
        }
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

    func setupHeader() {
        let filtered = data.filter { $0.item.isFinished  }
        let amount = filtered.count
        view?.setupHeader(title: isHidden ? "Показать" : "Скрыть", amount: amount)
    }
}

// MARK: - Private methods

private extension HomeViewModel {

    // MARK: - Fetch items -
    func fetchItems() {
        Task {
            do {
                let networkItems = try await self.mockNetwork.getAllTodoItems()
                DDLogInfo("Загрузили данные из сети. Обновляем кэш")
                networkItems.forEach {
                    try? self.fileCache.add(item: $0)
                }
                self.parse(items: networkItems)
            } catch {
                DDLogError("Ошибка чтения данных из сети, читаем данные из файла")
                do {
                    let fileItems = try await self.fileCache.load(from: self.fileName)
                    DDLogInfo("Загрузили данные из файла")
                    self.parse(items: fileItems)
                } catch {
                    DDLogError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Save items -
    func saveItems() {
        Task {
            do {
                try await fileCache.save(to: fileName)
                DDLogInfo("Данные успешно сохранены в файл")
            } catch {
                DDLogError(error)
            }
        }
    }

    // MARK: - Parse data -
    func parse(items: [TodoItem]) {
        if items.isEmpty {
            DDLogInfo("Набор пустой. Создаем дефолтный")
            let startArray = getStartArray()
            startArray.forEach {
                try? fileCache.add(item: $0)
            }
        }
        saveItems()
        self.data = items.map { TodoViewModel(item: $0) }
        self.data.forEach {
            $0.delegate = self
        }
        view?.items = self.data
        DispatchQueue.main.async { [weak self] in
            self?.view?.reloadData()
        }
    }

    // MARK: - Default info
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
            )
        ]
    }
}
