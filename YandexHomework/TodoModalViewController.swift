//
//  TodoModalViewController.swift
//  YandexHomework
//
//  Created by Fedor Penin on 27.07.2022.
//

import UIKit
import DesignSystem

final class TodoModalViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Public properties

    var isSaveButtonEnabled: Bool {
        get {
            saveButton.isEnabled
        }
        set {
            saveButton.isEnabled = newValue
        }
    }

    // MARK: - Private properties

    private var viewModel: TodoViewModel

    private var isLandscape: Bool = UIDevice.current.orientation.isLandscape {
        didSet {
            deleteButton.isHidden = isLandscape
            bodyStackView.isHidden = isLandscape
            if isLandscape {
                // Пока костыль, ищу способ лучше
                let bounds = UIScreen.main.bounds
                let minHeight = bounds.height > bounds.width ? bounds.width : bounds.height
                let barHeight = navigationController?.navigationBar.frame.maxY ?? 0
                textViewMinHeightConstraint?.constant = minHeight - Constants.padding - barHeight
            } else {
                textViewMinHeightConstraint?.constant = Constants.textViewMinHeight
            }
        }
    }

    private var textViewMinHeightConstraint: NSLayoutConstraint?

    // MARK: - Константы -

    private class Constants {
        static let padding: CGFloat = 16.0
        static let textViewMinHeight: CGFloat = 120
        static let deadlineViewMinHeight: CGFloat = 54
        static let cornerRdius: CGFloat = 16
        static let fonsize: CGFloat = 17
        static let spacing: CGFloat = 16
    }

    // MARK: - Вьюхи -

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentSize.width = 1
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = Constants.spacing
        stack.alignment = .fill
        return stack
    }()

    private lazy var bodyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.backgroundColor = Token.backSecondary.color
        stack.layer.cornerRadius = Constants.cornerRdius
        return stack
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = Constants.cornerRdius
        view.textContainerInset = UIEdgeInsets(
            top: Constants.padding,
            left: Constants.padding,
            bottom: Constants.padding,
            right: Constants.padding
        )
        view.font = UIFont.systemFont(ofSize: Constants.fonsize)
        view.isScrollEnabled = false
        view.keyboardDismissMode = .interactive
        view.text = "placeholder"
//        view.tintColor = UIColor.lightGray
        return view
    }()

    private lazy var disableButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.addTarget(self, action: #selector(saveTodo), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var deleteButton: UIButton = {
        var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
        backgroundConfig.backgroundColor = Token.backSecondary.color

        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = .init(
            top: Constants.padding,
            leading: Constants.padding,
            bottom: Constants.padding,
            trailing: Constants.padding
        )
        configuration.background = backgroundConfig

        let button = UIButton(configuration: configuration)
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Constants.fonsize)
        button.layer.cornerRadius = Constants.cornerRdius
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(deleteTodo), for: .touchUpInside)
        return button
    }()

    private lazy var calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale.autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        return datePicker
    }()

    private lazy var calendarWraper: UIView = {
        let wraper = UIView()
        wraper.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.widthAnchor.constraint(equalTo: wraper.widthAnchor, constant: -Constants.padding),
            calendarView.centerXAnchor.constraint(equalTo: wraper.centerXAnchor),
            calendarView.bottomAnchor.constraint(equalTo: wraper.bottomAnchor),
            calendarView.topAnchor.constraint(equalTo: wraper.topAnchor)
        ])
        calendarView.isHidden = true
        wraper.isHidden = true
        return wraper
    }()

    private lazy var calendarSeparator = separator

    private let importancyView = ImportancyView()

    private let deadlineView = DeadlineView()

    // MARK: - Init

    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure(with: viewModel.state)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit")
    }
}

// MARK: - Override

extension TodoModalViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Token.backPrimary.color
        title = "Дело"

        setupNavigationBarItems()

        setupViews()
        setupConstraints()
        setupGesturesAndObservers()

        scrollView.delegate = self
        textView.delegate = self

        importancyView.valueDidChange = { [weak self] value in
            self?.viewModel.importancyDidChange(importancy: value)
        }

        saveButton.isEnabled = false

//        viewModel.viewDidLoad()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        isLandscape = UIDevice.current.orientation.isLandscape
    }
}

// MARK: - UITextViewDelegate

extension TodoModalViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.textDidChange(text: textView.text)

        if textView.text.isEmpty {
            textView.text = "Что нужно сделать?"
            textView.textColor = UIColor.lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        viewModel.textDidChange(text: newText)
        return false
    }
}

// MARK: - TodoModalProtocol

extension TodoModalViewController: TodoModalProtocol {

    func closeModal(animated: Bool) {
        self.dismiss(animated: animated)
    }

    func configure(with viewState: TodoViewState) {
        set(deadline: viewState.deadline)
        set(text: !viewState.text.isEmpty ? viewState.text : nil)
        set(importancy: viewState.importancy)
        if let deadline = viewState.deadline {
            set(date: deadline)
        }
    }

    func setupDeadline(with date: Date) {
        set(deadline: date)
        set(date: date)
    }

    func showCalendar() {
        calendarView.layer.opacity = 1
        calendarSeparator.layer.opacity = 1
        UIView.animate(withDuration: 0.25) {
            self.calendarView.isHidden = false
            self.calendarSeparator.isHidden = false
            self.calendarWraper.isHidden = false
        }
    }

    func dismissCalendar() {
        calendarView.layer.opacity = 0
        calendarSeparator.layer.opacity = 0
        UIView.animate(withDuration: 0.25) {
            self.calendarView.isHidden = true
            self.calendarSeparator.isHidden = true
            self.calendarWraper.isHidden = true
        }
    }
}

// MARK: - Private methods

private extension TodoModalViewController {

    var separator: UIView {
        let separator = UIView()
        let content = UIView()
        content.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Token.supportSeparator.color
        NSLayoutConstraint.activate([
            content.heightAnchor.constraint(equalToConstant: 0.5),
            separator.topAnchor.constraint(equalTo: content.topAnchor),
            separator.leftAnchor.constraint(equalTo: content.leftAnchor, constant: Constants.padding),
            separator.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -Constants.padding),
            separator.heightAnchor.constraint(equalTo: content.heightAnchor)
        ])
        return content
    }

    // MARK: - Настройка бара -

    func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: disableButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

    // MARK: - Настройка View -

    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(bodyStackView)
        stackView.addArrangedSubview(deleteButton)

        let subviews: [UIView] = [importancyView, separator, deadlineView, calendarSeparator, calendarWraper]

        subviews.forEach {
            bodyStackView.addArrangedSubview($0)
        }

        calendarSeparator.isHidden = true

        deadlineView.valueDidChange = { [weak self] value in
            self?.viewModel.deadlineDidChange(isEnabled: value)
        }

        deadlineView.deadLineDidClicked = { [weak self] in
            self?.viewModel.deadLineDidClick()
        }
    }

    // MARK: - Настройка констреинтов -

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.padding),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.padding),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            deadlineView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.deadlineViewMinHeight)
        ])

        textViewMinHeightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewMinHeight)
        textViewMinHeightConstraint?.isActive = true
    }

    // MARK: - настройка обзерверов -

    func setupGesturesAndObservers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - Установка значений -

    func set(date: Date) {
        calendarView.setDate(date, animated: false)
    }

    func set(text: String?) {
        guard let text = text else {
            textView.text = "Что нужно сделать?"
            textView.textColor = UIColor.lightGray
            return
        }
        textView.text = text
        textView.textColor = Token.labelPrimary.color

        saveButton.isEnabled = !text.isEmpty
    }

    func set(importancy: Importancy) {
        importancyView.importancy = importancy
    }

    func set(deadline: Date?) {
        deadlineView.deadline = deadline
    }
}

// MARK: - Action extension

extension TodoModalViewController {

    @objc func clickCancel() {
        dismiss(animated: true)
    }

    @objc func datePickerChanged(picker: UIDatePicker) {
        viewModel.datePickerChanged(date: picker.date)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func saveTodo() {
        viewModel.saveButtonDidTap()
    }

    @objc func deleteTodo() {
        viewModel.deleteButtonDidTap()
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollView.contentInset.bottom = keyboardHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}
