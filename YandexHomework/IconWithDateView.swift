//
//  IconWithDateView.swift
//  YandexHomework
//
//  Created by Fedor Penin on 02.08.2022.
//

import UIKit
import DesignSystem

// MARK: - IconWithDateModel model

final class IconWithDateModel {

    /// Иконка с датой
    var icon: Icon

    /// Дата
    var date: Date

    init(icon: Icon, date: Date) {
        self.icon = icon
        self.date = date
    }
}

final class IconWithDateView: UIStackView {

    // MARK: - Private properties

    private class Constants {
        static let fontsize: CGFloat = 16.0
    }

    let iconView: UIImageView = {
        let view = UIImageView()
        view.tintColor = Token.labelTertiary.color
        return view
    }()

    let titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = Token.labelTertiary.color
        view.font = UIFont.systemFont(ofSize: Constants.fontsize)
        return view
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func configure(with model: IconWithDateModel) {
        iconView.image = model.icon.image

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        titleLabel.text = dateFormatter.string(from: model.date)
    }
}

// MARK: - IconWithDateView extension

private extension IconWithDateView {

    func setupViews() {
        axis = .horizontal
        distribution = .equalSpacing
        spacing = 4
        alignment = .center

        addArrangedSubview(iconView)
        addArrangedSubview(titleLabel)
    }
}
