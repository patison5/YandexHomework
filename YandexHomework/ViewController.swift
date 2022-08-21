//
//  ViewController.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import UIKit

final class ViewController: UIViewController {

    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Token.backPrimary.color

        button.setTitle("Открыть домашку", for: .normal)
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        button.backgroundColor = Token.backSecondary.color
        button.setTitleColor(UIColor.red, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc private func didTapButton() {
        let viewModel: TodoViewModel = TodoViewModel()
        let controller = TodoModalViewController(viewModel: viewModel)
        viewModel.view = controller

        let navC = UINavigationController(rootViewController: controller)
        present(navC, animated: true)
    }
}
