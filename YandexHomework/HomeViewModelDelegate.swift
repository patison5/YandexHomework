//
//  HomeViewModelDelegate.swift
//  YandexHomework
//
//  Created by Fedor Penin on 06.08.2022.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {

    /// Оповестить об изменении таски
    /// - Parameters:
    ///   - model: Вью модель
    ///   - state: Стейт
    func didUpdate(model: TodoViewModel, state: TodoViewState)

    /// Оповестить об удалении таски
    /// - Parameter model: Вью модель
    func didDelete(model: TodoViewModel)
}
