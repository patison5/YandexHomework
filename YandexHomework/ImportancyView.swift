//
//  ImportancyView.swift
//  YandexHomework
//
//  Created by Fedor Penin on 28.07.2022.
//

import UIKit

/// Вью важности дела
final class ImportancyView: UIView {

    /// Отследить изменение важности
    var valueDidChange: ((Importancy) -> Void)?

    /// Данные о важности дела
    var importancy: Importancy? {
        didSet {
            guard let importancy = importancy else {
                return
            }

            switch importancy {
            case .normal:
                segmentedControl.selectedSegmentIndex = 0
            case .unImportant:
                segmentedControl.selectedSegmentIndex = 1
            case .important:
                segmentedControl.selectedSegmentIndex = 2
            }
        }
    }


    // MARK: - Private properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = Token.labelPrimary.color
        return label
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        sc.insertSegment(with: Icon.iconArrowDown20.image, at: 0, animated: false)
        sc.insertSegment(withTitle: "нет", at: 1, animated: false)
        sc.insertSegment(withTitle: "‼️", at: 2, animated: false)
        sc.selectedSegmentIndex = 1
        sc.backgroundColor = Token.supportOverlay.color
        sc.selectedSegmentTintColor = Token.backElevated.color

        sc.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        sc.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .touchUpInside)
        return sc
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods

private extension ImportancyView {

    func setupViews() {
        [titleLabel, segmentedControl].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),

            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
            segmentedControl.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}


// MARK: - Action extension

extension ImportancyView {

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            valueDidChange?(Importancy.normal)
        case 1:
            valueDidChange?(Importancy.unImportant)
        case 2:
            valueDidChange?(Importancy.important)
        default:
            valueDidChange?(Importancy.normal)
        }
    }
}
