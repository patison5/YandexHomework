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
    private let network: NetworkServiceProtocol = NetworkService()
}

// MARK: - HomeViewModelDelegate

extension HomeViewModel: HomeViewModelDelegate {

    func didUpdate(model: TodoViewModel, state: TodoViewState) {
        view?.showStatusIndicator()
        let newItem = TodoItem(
            id: model.item.id,
            text: state.text,
            importancy: state.importancy,
            deadline: state.deadline,
            isFinished: state.isFinished,
            createdAt: state.createdAt,
            changedAt: Date()
        )
        update(with: newItem, model: model)
    }

    func didDelete(model: TodoViewModel) {
        view?.showStatusIndicator()
        let id = model.item.id
        try? fileCache.removeItem(by: id)
        saveItems()
        data.removeAll { $0.item.id == id }
        view?.items = data

        Task {
            Variables.shared.isDirty ? await fetchItemsByPatch() : await deleteItemFromServer(by: id)
        }

        DispatchQueue.main.async {
            self.view?.reloadData()
        }
    }
}

// MARK: - HomeViewModelProtocol

extension HomeViewModel: HomeViewModelProtocol {

    func viewDidLoad() {
        view?.showStatusIndicator()
        Task {
            if Variables.shared.isInited || Variables.shared.isDirty {
                await fetchItemsByPatch()
            } else {
                await fetchItemsByGet()
            }
            Variables.shared.isInited = true
        }
    }

    func hideStatusIndicator() {
        DispatchQueue.main { [weak self] in
            self?.view?.hideStatusIndicator()
        }
    }

    func createTask(with text: String) {
        if text.isEmpty { return }
        view?.showStatusIndicator()
        Task {
            let newModel = TodoViewModel(item: TodoItem(text: text))
            Variables.shared.isDirty ? await fetchItemsByPatch() : await createTask(with: newModel)
        }
    }

    func delete(at indexPath: IndexPath) {
        view?.showStatusIndicator()
        Task {
            Variables.shared.isDirty ? await fetchItemsByPatch() : await deleteItem(at: indexPath)
        }
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
        view?.showStatusIndicator()
        Task {
            Variables.shared.isDirty ? await fetchItemsByPatch() : await updateTask(with: model, at: at)
        }
        DDLogInfo("Скоро тут (или не тут) будет обработчик ошибок...")
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

    // MARK: - Запросы на сервер -

    /// Смержить данные с сервером
    func fetchItemsByPatch() async {
        fileCache.load(from: fileName) { [weak self] result in
            switch result {
            case let .success(fileItems):
                DDLogInfo("Загрузили данные из файла")
                guard let fileModels = self?.parse(items: fileItems) else { return }
                let modelsToPatch = fileModels.compactMap { ApiTodoItem.parse(from: $0) }
                let apiModel = ApiTodoListModel(list: modelsToPatch, revision: Variables.shared.revision, status: "ok")
                self?.network.patch(with: apiModel) { res in
                    switch res {
                    case let .success(networkModel):
                        DDLogInfo("Получили смерженные данные из сети")
                        Variables.shared.revision = networkModel.revision
                        self?.manageFetchedModels(models: networkModel)
                    case let .failure(error):
                        DDLogInfo("Словили приколюху от сервера (PATCH всех элементов)")
                        DDLogError(error)
                    }
                    self?.hideStatusIndicator()
                }
            case let .failure(error):
                DDLogError(error.localizedDescription)
            }
        }
    }

    /// Получить достоверные данные с сервера
    func fetchItemsByGet() async {
        network.get { [weak self] res in
            switch res {
            case let .success(networkModel):
                DDLogInfo("Получили достоверные данные из сети")
                Variables.shared.revision = networkModel.revision
                self?.manageFetchedModels(models: networkModel)
            case let .failure(error):
                DDLogInfo("Словили приколюху от сервера (GET всех элементов)")
                DDLogError(error)
            }
            self?.hideStatusIndicator()
        }
    }

    /// Преобразовать набор данных из сети в набор вью-моделей
    /// - Parameter models: Набор бизнес данных из сети
    func manageFetchedModels(models: ApiTodoListModel) {
        let parsed = models.list.compactMap { TodoViewModel(item: $0) }
        parsed.forEach {
            $0.delegate = self
        }
        data = parsed
        view?.items = parsed
        DispatchQueue.main.async { [weak self] in
            self?.view?.reloadData()
        }
        data.forEach { try? fileCache.add(item: $0.item)}
        saveItems()
    }

    /// Отправить запрос на удаление  элемента на стороне сервера
    /// - Parameter id: Уникальный идентификатор элемента
    func deleteItemFromServer(by id: String) async {
        network.delete(by: id) { [weak self] res in
            switch res {
            case let .success(networkModel):
                Variables.shared.revision = networkModel.revision
                DDLogError("Удален на сервере")
            case let .failure(error):
                guard let error = error as? ApiError else {
                    DDLogInfo("Словили приколюху от сервера (Удаление элемента)")
                    DDLogError(error)
                    return
                }
                DDLogError(error.rawValue)
            }
            self?.hideStatusIndicator()
        }
    }

    /// Отправить запрос на добавление элемента на стороне сервера
    /// - Parameter model: Вью-модель претендента на добавление
    func addItemToServer(model: TodoViewModel) async {
        guard let apiElement = ApiTodoItem.parse(from: model) else { return }
        let apiModel = ApiTodoElementModel(element: apiElement, revision: Variables.shared.revision, status: "ok")
        network.add(by: apiModel) { [weak self] res in
            switch res {
            case let .success(networkModel):
                DDLogInfo("Элемент успешно добавлен на сервер")
                Variables.shared.revision = networkModel.revision
            case let .failure(error):
                DDLogInfo("Словили приколюху от сервера (Добавление элемента)")
                DDLogError(error)
                if error as? ApiError == .wrongRequest {
                    self?.retryWithPatch()
                }
            }
            self?.hideStatusIndicator()
        }
    }

    // Вот тут начинает баговать лоадер... (если после патча начать добавлять элементы)
    func retryWithPatch() {
        Task {
            await fetchItemsByPatch()
        }
    }

    /// Отправить запрос на изменение существующего элемента на стороне сервера
    /// - Parameter model: Вью-модель претендента на изменение
    func changeItemOnServer(model: TodoViewModel) async {
        guard let apiElement = ApiTodoItem.parse(from: model) else { return }
        let apiModel = ApiTodoElementModel(element: apiElement, revision: Variables.shared.revision, status: "ok")
        network.update(by: apiModel) { [weak self] res in
            switch res {
            case let .success(networkModel):
                DDLogInfo("Элемент успешно обновлен на сервере")
                Variables.shared.revision = networkModel.revision
            case let .failure(error):
                DDLogInfo("Словили приколюху от сервера (Обновление элемента)")
                DDLogError(error)
            }
            self?.hideStatusIndicator()
        }
    }

    // MARK: - Подготовка данных и вызов методов на общение с сервером -

    /// Создать новую задачу.
    /// Помещает  задачу в список кэша.
    /// Отправляет  запрос на добавление задачи на стороне сервера
    /// - Parameter model: Претендент на добавление
    func createTask(with model: TodoViewModel) async {
        data.append(model)
        try? fileCache.add(item: model.item)
        self.view?.items = self.data
        self.saveItems()

        // отправка инфы на добавление на сервер
        await addItemToServer(model: model)

        DispatchQueue.main {
            self.view?.insertRow(at: IndexPath(row: self.data.count - 1, section: 0))
        }
    }

    /// Сохранить данные в кэшэ
    func saveItems() {
        fileCache.save(to: fileName) { result in
            switch result {
            case .success:
                DDLogInfo("Данные успешно сохранены в файл")
            case let .failure(error):
                DDLogError(error)
            }
        }
    }

    /// Преобзразовать набор из бизнес моделей в набор настроенных вью-моделей.
    /// - Parameter items: Набор бизнес моделей тасок
    /// - Returns: Набор вью моделей
    func parse(items: [TodoItem]) -> [TodoViewModel] {
        var data = items
        if items.isEmpty {
            DDLogInfo("Набор пустой. Создаем дефолтный")
            data = Debug.getStartArray()
            data.forEach {
                try? fileCache.add(item: $0)
            }
            saveItems()
        }
        let models = data.map { TodoViewModel(item: $0) }
        models.forEach {
            $0.delegate = self
        }
        return models
    }

    /// Обновить данные в кэшэ и отправить запрос синхронизации с сервером. Вызывается в момент изменения в модальном окне.
    /// - Parameters:
    ///   - item: Бизнес модель
    ///   - model: Вью-модель
    func update(with item: TodoItem, model: TodoViewModel) {
        let isExist = data.contains { $0.item.id == item.id  }
        if isExist {
            try? fileCache.change(item: item)

            Task {
                Variables.shared.isDirty ?
                    await fetchItemsByPatch() :
                    await changeItemOnServer(model: TodoViewModel(item: item))
            }
        } else {
            data.append(model)
            try? fileCache.add(item: item)

            Task {
                Variables.shared.isDirty ?
                    await fetchItemsByPatch() :
                    await addItemToServer(model: TodoViewModel(item: item))
            }
        }
        saveItems()
        view?.items = data

        DispatchQueue.main.async { [weak self] in
            self?.view?.reloadData()
        }
    }

    /// Обновить данные таски в кэши и отправить запрос синхрониазции на сервер. Вызывается в момент изменения таски в главном окне
    /// - Parameters:
    ///   - model: Вью-модель таски
    ///   - at: Позиция таски в таблице
    func updateTask(with model: TodoViewModel, at: IndexPath) async {
        guard let view = self.view else { return }

        if !self.isHidden {
            model.state.isFinished.toggle()
            model.item = model.item.toggleComplete()
            try? fileCache.change(item: model.item)
            saveItems()
            view.items.remove(at: at.row)
        } else {
            model.state.isFinished.toggle()
            model.item = model.item.toggleComplete()
            try? fileCache.change(item: model.item)
            self.saveItems()
        }

        await changeItemOnServer(model: model)

        DispatchQueue.main.async {
            if !self.isHidden {
                view.deleteRow(at: at)
            } else {
                view.reloadRow(at: at)
            }
            self.setupHeader()
        }
    }

    /// Удалить таску по indexPath и отправить запрос синхронизации с сервером. Вызывается в момент изменения таски в главном окне
    /// - Parameter indexPath: Позиция элемента  в таблице
    func deleteItem(at indexPath: IndexPath) async {
        guard let view = view else { return }
        var id: String

        if !isHidden {
            id = view.items[indexPath.row].item.id
            try? fileCache.removeItem(by: id)
            data.removeAll { $0.item.id == id }
            view.items.remove(at: indexPath.row)
        } else {
            id = data[indexPath.row].item.id
            try? fileCache.removeItem(by: id)
            data.remove(at: indexPath.row)
            view.items = data
        }
        saveItems()

        await deleteItemFromServer(by: id)

        DispatchQueue.main.async {
            view.deleteRow(at: indexPath)
            self.setupHeader()
        }
    }
}
