//
//  TaskInputCell.swift
//  YandexHomework
//
//  Created by Fedor Penin on 05.08.2022.
//

import UIKit

/// Ячейка для таблицы с задачами
final class TaskInputCell: UITableViewCell {


    // MARK: - Public properties

    var action: ((String) -> Void)?


    // MARK: - Static properties

    static let identifier: String = "TaskInputCell"


    // MARK: - Private properties

    private let textField: UITextField = {
        let view = UITextField()
        view.placeholder = "Новое"
        return view
    }()


    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        textField.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TaskInputCell {

    func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = Token.backSecondary.color
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 54),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
}

extension TaskInputCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        action?(text)
        textField.text = ""
        return false
    }
}
