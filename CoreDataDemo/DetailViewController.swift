//
//  DetailViewController.swift
//  CoreDataDemo
//
//  Created by Irina Kopchenova on 12.03.2020.
//  Copyright © 2020 Mikhail Scherbina. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    func updatedTask(oldName: String, newName: String, indexPath: IndexPath)
    func addTask(newName: String)
}

class DetailViewController: UIViewController, TaskListViewControllerDelegate {
    
    var taskDetail: UITextField!
    
    var oldName: String?
    var index: IndexPath?
    var taskVC: TaskListViewController?
    var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        delegate = taskVC
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(DetailViewController.done))
        
       initTaskDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         taskDetail.text = oldName ?? ""
    }
    
    private func initTaskDetail() {
        taskDetail = UITextField(frame: .zero)
        taskDetail.placeholder = "Task Name"
        taskDetail.borderStyle = .roundedRect
        taskDetail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskDetail)
        
        NSLayoutConstraint.activate([
            taskDetail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskDetail.centerYAnchor.constraint(equalTo: view.readableContentGuide.topAnchor, constant: 30),
            taskDetail.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 16),
            taskDetail.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -16)
            ])
    }

    @objc func done() {
        if let new = taskDetail.text, new != "" {
            if let old = oldName, let index = index  {
                print("Old name - \(old) and New name -\(new)")
                delegate?.updatedTask(oldName: old, newName: new, indexPath: index)
            } else {
                delegate?.addTask(newName: new)
            }
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // Confirm Protocol TaskListTabeViewController
    func sendTask(name: String?, indexPath: IndexPath) {
        oldName = name
        index = indexPath
    }
    
    func emptyTask() {
        oldName = ""
    }

}

