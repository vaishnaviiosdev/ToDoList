
import Foundation
import UIKit

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
let DB_Context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
let COREDATA_MANAGER = CoreDataManager.shared
let TASK_CATEGORY = "TaskCategory"
let TASK_LIST = "TaskList"

