//
//  TodoModalViewController.swift
//  YandexHomework
//
//  Created by Fedor Penin on 27.07.2022.
//

import UIKit

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

    private var viewModel: TodoViewModel


    // MARK: - Private properties

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentSize.width = 1
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 16.0
        stack.alignment = .fill
        return stack
    }()

    private let bodyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.backgroundColor = Token.backSecondary.color
        stack.layer.cornerRadius = 16
        return stack
    }()

    private let textView: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 16
        view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.font = UIFont.systemFont(ofSize: 17)
        view.isScrollEnabled = false
        view.keyboardDismissMode = .interactive
        view.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt i"
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
        configuration.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.background = backgroundConfig

        let button = UIButton(configuration: configuration)
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(deleteTodo), for: .touchUpInside)
        return button
    }()

    private let importancyView: ImportancyView = {
        let view = ImportancyView()
        return view
    }()

    private let deadlineView: DeadlineView = {
        let view = DeadlineView()
        return view
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
            calendarView.widthAnchor.constraint(equalTo: wraper.widthAnchor, constant: -16),
            calendarView.centerXAnchor.constraint(equalTo: wraper.centerXAnchor),
            calendarView.bottomAnchor.constraint(equalTo: wraper.bottomAnchor),
            calendarView.topAnchor.constraint(equalTo: wraper.topAnchor)
        ])
        calendarView.isHidden = true
        wraper.isHidden = true
        return wraper
    }()

    private lazy var calendarSeparator = separator

    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        viewModel.viewDidLoad()
    }
}


// MARK: - UITextViewDelegate

extension TodoModalViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.textDidChange(text: textView.text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        viewModel.textDidChange(text: newText)
        return false
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
            separator.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 16),
            separator.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -16),
            separator.heightAnchor.constraint(equalTo: content.heightAnchor)
        ])
        return content
    }

    func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: disableButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }

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

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            deadlineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])
    }

    func setupGesturesAndObservers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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


// MARK: - Internal

extension TodoModalViewController {

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

    func set(date: Date) {
        calendarView.setDate(date, animated: false)
    }

    func set(text: String) {
        textView.text = text
    }

    func set(importancy: Importancy) {
        importancyView.importancy = importancy
    }

    func set(deadline: Date?) {
        deadlineView.deadline = deadline
    }
}
