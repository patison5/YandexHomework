//
//  ViewController.swift
//  Homework
//
//  Created by Fedor Penin on 25.07.2022.
//

import UIKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let test1 = TodoItem(id: "Todo1", text: "Todo1", deadline: Date(), isFinished: false, startDate: Date(), finishDate: nil)
        let test2 = TodoItem(id: "Todo2", text: "Todo2", importancy: .normal, deadline: Date(), isFinished: false, startDate: Date(), finishDate: nil)
        let test3 = TodoItem(id: "Todo3", text: "Todo3", importancy: .important, deadline: Date(), isFinished: false, startDate: Date(), finishDate: nil)

        let fileName = "TodoData.json"
        
        do {
            let cache = FileCache(fileName: fileName)
            try cache.add(item: test1)
            try cache.add(item: test2)
            try cache.add(item: test3)
            try cache.pushItems(to: fileName)
            try cache.removeItem(by: "Todo1")
            try cache.pullItems(from: fileName)
            print(cache.items.count)
            
            cache.items.forEach {
                print($0.id)
            }
        } catch {
            print(error)
        }
    }
}
