//
//  DataManager.swift
//  CoreDataDemo
//
//  Created by Irina Kopchenova on 11.03.2020.
//  Copyright © 2020 Mikhail Scherbina. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    //private var tasks = [Task]()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveData(for taskName: String, completion: @escaping (Task) -> Void) {
        let context = persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { print("Unable get entity description"); return }
        let task = NSManagedObject(entity: entityDescription, insertInto: context) as! Task
        task.name = taskName
        do {
            try context.save()
            completion(task)
        } catch {
            print(error)
        }
    }
    
    func fetchData() -> [Task] {
        var tasks = [Task]()
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(fetchRequest)
            print("Return total tasks - \(tasks.count)")
        } catch let error {
            print(error)
        }
        return tasks
    }
    
    func removeTask(for task: Task) {
        let context = persistentContainer.viewContext
        context.delete(task)
        saveContext()
    }
    
    func updateSomeTask(from oldName: String, to newName: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name = %@", oldName)
        do {
            let tasksForUpdate = try context.fetch(fetchRequest)
            print("There is \(tasksForUpdate.count) task(s)")
            if tasksForUpdate.count == 1 {
                guard let someTask = tasksForUpdate.first else { return }
                someTask.setValue(newName, forKey: "name")
            } else { print("Too many tasks with that name") }
        } catch let error {
            print(error)
        }
        saveContext()
    }
}
