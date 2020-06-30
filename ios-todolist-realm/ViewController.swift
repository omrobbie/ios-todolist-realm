//
//  ViewController.swift
//  ios-todolist-realm
//
//  Created by omrobbie on 30/06/20.
//  Copyright © 2020 omrobbie. All rights reserved.
//

import UIKit
import RealmSwift

// For Realm object, we have to use class instead of struct.
class Item: Object  {

    @objc dynamic var title: String = ""
    @objc dynamic var status: Bool = false
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let realm = try! Realm()
    private var items: Results<Item>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get file location
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        setupList()
        loadData()
    }

    private func setupList() {
        title = "Todo List"
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func saveData(_ item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }

    private func loadData() {
        items = realm.objects(Item.self)
        tableView.reloadData()
    }

    @IBAction func btnAddTapped(_ sender: Any) {
        var textField = UITextField()

        let alertVC = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let actionAdd = UIAlertAction(title: "Add", style: .default) { (_) in
            let item = Item()
            item.title = textField.text!
            item.status = false

            self.saveData(item)
            self.tableView.reloadData()
        }

        alertVC.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new item..."
            textField = alertTextField
        }

        alertVC.addAction(actionCancel)
        alertVC.addAction(actionAdd)

        present(alertVC, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.status ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()

        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.status = !item.status
                }
            } catch {
                print(error.localizedDescription)
                return
            }

            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = items?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
}
