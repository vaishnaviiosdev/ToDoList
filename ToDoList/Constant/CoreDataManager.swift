
import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    var taskCategories: [TaskCategory] = []
    var taskList: [TaskList] = []
    
    func addTaskCategory(categoryName: String, categoryImage: String) {
        let taskCategory = TaskCategory(context: DB_Context)
        taskCategory.taskcategory_name = categoryName
        taskCategory.task_image = categoryImage
        COREDATA_MANAGER.savedata()
    }
    
    func createTask(title:String,latitude:Double,longitude:Double,description:String,dueDate:String,priority:String,categoryName:String) {
        let createTask = TaskList(context: DB_Context)
        createTask.tasktitle = title
        createTask.latitude = latitude
        createTask.longitude = longitude
        createTask.taskdescription = description
        createTask.taskduedate = dueDate
        createTask.taskpriority = priority
        createTask.taskcategory = categoryName
        COREDATA_MANAGER.savedata()
    }
    
    func createtaskwithstatus(tasktitle:String, latitude:Double, longitude:Double,taskduedate:String,taskstatus:String) {
        let createTask = TaskStatusList(context: DB_Context)
        createTask.tasktitle = tasktitle
        createTask.latitude = latitude
        createTask.longitude = longitude
        createTask.taskduedate = taskduedate
        createTask.taskstatus = taskstatus
        COREDATA_MANAGER.savedata()
    }
    
    func fetchTaskCategories() {
        let fetchRequest: NSFetchRequest<TaskCategory> = NSFetchRequest<TaskCategory>(entityName: "TaskCategory")

            do {
                taskCategories = try DB_Context.fetch(fetchRequest)
            }
        catch {
                print("Failed to fetch TaskCategories: \(error)")
            }
    }
    
    func fetchTaskList() {
        let fetchRequest: NSFetchRequest<TaskList> = TaskList.fetchRequest()

            do {
                self.taskList = try DB_Context.fetch(fetchRequest)
                print("The tasklist count is \(self.taskList.count)")
            }
        catch {
                print("Failed to fetch TaskCategories: \(error)")
            }
        }
        
    func savedata() {
        do {
            try DB_Context.save()
        }
        catch {
            print("***Error in Insert Data on Table :---> \(error)***")
        }
    }
    
}

