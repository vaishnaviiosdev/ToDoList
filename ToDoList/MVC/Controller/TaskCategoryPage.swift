
import UIKit
import CoreData

class TaskCategoryPage: UIViewController, UITextFieldDelegate {
    
    var categoryName = ""
    var taskCategories: [TaskCategory] = []
    var previousSelectedIndex: IndexPath?

    @IBOutlet weak var categoryTableview: UITableView!
    @IBOutlet weak var taskTitleTextfield: UITextField!
    @IBOutlet weak var addTitleView: UIView!
    @IBOutlet weak var tickView: UIView!
    @IBOutlet weak var addView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskTitleTextfield.delegate = self
        self.addStaticTaskCategoriesIfNeeded()
        setRoundCorner(iphone: 25, ipad: 40, customView: self.tickView)
        setRoundCorner(iphone: 25, ipad: 40, customView: self.addView)
    }
    
    @IBAction func didCancelBtnTap(_ sender: Any) {
        self.addTitleView.isHidden = true
    }
    
    @IBAction func didAddBtnTap(_ sender: Any) {
        if self.taskTitleTextfield.text != "" || self.taskTitleTextfield.text != nil {
            COREDATA_MANAGER.addTaskCategory(categoryName: self.taskTitleTextfield.text ?? "", categoryImage: "default")
            self.addTitleView.isHidden = true
            self.fetchTaskCategories()
        }
    }
    
    @IBAction func didAddTitleBtnTap(_ sender: Any) {
        self.addTitleView.isHidden = false
    }
    
    @IBAction func didSelectBtnTap(_ sender: Any) {
        self.dismiss(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name("CategorySelected"), object: nil, userInfo: ["categoryName": self.categoryName])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.taskTitleTextfield.resignFirstResponder()
            return true
    }
    
    func addStaticTaskCategoriesIfNeeded() {
        let fetchRequest: NSFetchRequest<TaskCategory> = NSFetchRequest<TaskCategory>(entityName: "TaskCategory")

        do {
            let existingCategories = try DB_Context.fetch(fetchRequest)
            
            if existingCategories.isEmpty {
                addStaticCategories()
            }
            else {
                self.fetchTaskCategories()
            }
        }
        catch {
            print("Failed to fetch TaskCategories: \(error)")
        }
    }
    
    func addStaticCategories() {
        let taskCategory1 = TaskCategory(context: DB_Context)
        taskCategory1.taskcategory_name = "Work"
        taskCategory1.task_image = "work"
        
        let taskCategory2 = TaskCategory(context: DB_Context)
        taskCategory2.taskcategory_name = "Home"
        taskCategory2.task_image = "home"
        
        let taskCategory3 = TaskCategory(context: DB_Context)
        taskCategory3.taskcategory_name = "Purchase"
        taskCategory3.task_image = "personal"
        COREDATA_MANAGER.savedata()
        self.fetchTaskCategories()
    }
    
    func fetchTaskCategories() {
        let fetchRequest: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        
        do {
            taskCategories = try DB_Context.fetch(fetchRequest)
            self.categoryTableview.reloadData()
        }
        catch {
            print("Failed to fetch TaskCategories: \(error)")
        }
    }
}

extension TaskCategoryPage: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableviewCell", for: indexPath) as! categoryTableviewCell
        let Dict = self.taskCategories[indexPath.row]
        cell.categoryImageView.image = UIImage(named: Dict.task_image ?? "default")
        cell.categoryNameLbl.text = Dict.taskcategory_name ?? ""
        cell.checkBoxImageView.image = UIImage(named: "empty")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            if let categoryCell = cell as? categoryTableviewCell {
                categoryCell.checkBoxImageView.image = UIImage(named: "empty")
            }
        }
            
        let currentCell = tableView.cellForRow(at: indexPath) as! categoryTableviewCell
        currentCell.checkBoxImageView.image = UIImage(named: "choice")
        
        let selectedCategory = taskCategories[indexPath.row]
        self.categoryName = selectedCategory.taskcategory_name ?? ""
        
        previousSelectedIndex = indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 110
        }
        else {
            return 70
        }
    }
}

class categoryTableviewCell: UITableViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var checkBoxImageView: UIImageView!
}

