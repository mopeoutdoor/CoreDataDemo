//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Irina Kopchenova on 11.03.2020.
//  Copyright © 2020 Mikhail Scherbina. All rights reserved.
//

import UIKit

protocol TaskListViewControllerDelegate {
    func sendTask(name: String?, indexPath: IndexPath)
    func emptyTask()
}

class TaskListViewController: UITableViewController, DetailViewControllerDelegate {
    
    private let cellId = "cell"
    private var tasks: [Task] = []
    let detailVC: DetailViewController = DetailViewController()
    var delegate: TaskListViewControllerDelegate!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tasks = DataManager.shared.fetchData()
        delegate = detailVC
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskForDelete = tasks[indexPath.row]
            DataManager.shared.removeTask(for: taskForDelete)
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        detailVC.taskVC = self
        detailVC.delegate = self
        self.navigationController?.pushViewController(detailVC, animated: true)
        delegate.sendTask(name: task.name, indexPath: indexPath)
    }
}


extension TaskListViewController {
    private func setupNavigationBar() {
        title = "Task List"
        guard let navBarAppearance = navigationController?.navigationBar else { return }
        navBarAppearance.isTranslucent = true
        navBarAppearance.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        navBarAppearance.prefersLargeTitles = true
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask))
        navBarAppearance.tintColor = .white
    }
    
    @objc private func addNewTask() {
        detailVC.taskVC = self
        self.navigationController?.pushViewController(detailVC, animated: true)
        delegate.emptyTask()
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            DataManager.shared.saveData(for: task, completion: { (task) in
                self.tasks.append(task)
                let cellIndex = IndexPath(row: self.tasks.count - 1, section: 0)
                self.tableView.insertRows(at: [cellIndex], with: .automatic)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        present(alert, animated: true)
    }
    
    func updatedTask(oldName: String, newName: String, indexPath: IndexPath) {
        DataManager.shared.updateSomeTask(from: oldName, to: newName)
        tasks[indexPath.row].name = newName
        let cellIndex = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [cellIndex], with: .automatic)
    }
    
    func addTask(newName: String) {
        print("New name \(newName)")
        DataManager.shared.saveData(for: newName, completion: { (task) in
            print("Add task \(task) to total tasks \(self.tasks)")
            self.tasks.append(task)
            let cellIndex = IndexPath(row: self.tasks.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        })
    }
}
