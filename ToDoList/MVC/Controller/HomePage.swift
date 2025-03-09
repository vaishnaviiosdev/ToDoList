
import UIKit
import CoreData
import DropDown
import CoreLocation
import UserNotifications

class HomePage: UIViewController, UITextFieldDelegate {
    
    var taskList: [TaskList] = []
    var filteredData: [TaskList] = []
    var allStatusList: [TaskStatusList] = []
    var taskStatusList = ["Completed","Pending","Overdue"]
    var sorting = ["Due date","Priority","Category"]
    
    var selectedCategory: String? = nil
    var locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var plusView: UIView!
    @IBOutlet weak var taskListTableview: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var topView: GradientView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var noDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        self.searchTextfield.delegate = self
        self.askNotificationPermission()
        self.checkLocationAuthorizationStatus()
        COREDATA_MANAGER.fetchTaskCategories()
        setRoundCorner(iphone: 25, ipad: 40, customView: self.plusView)
   }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchTaskList()
    }
    
    func askNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.fetchTaskStatusList()
                }
            }
            else {
                print("Notification permission denied.")
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        self.filterItems(with: updatedText)
        return true
    }
    
    func filterItems(with searchText: String) {
        if searchText.isEmpty {
            filteredData = taskList
        }
        else {
             filteredData = taskList.filter { task in
                 if let title = task.tasktitle {
                     return title.lowercased().contains(searchText.lowercased())
                 }
                 return false
             }
         }
        print("The filtered data count is \(filteredData.count)")
        self.taskListTableview.reloadData()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filteredData = taskList
        self.taskListTableview.reloadData()
        return true
    }
    
    func fetchTaskStatusList() {
        let fetchRequest: NSFetchRequest<TaskStatusList> = TaskStatusList.fetchRequest()
        do {
            self.allStatusList = try DB_Context.fetch(fetchRequest)
            self.scheduleNotificationsForTasks()
        }
        catch {
            print("Failed to fetch TaskCategories: \(error)")
        }
    }
    
    //Local Notification:-
    func scheduleNotificationsForTasks() {
        let currentDate = Date()
        
        for task in self.allStatusList {
            guard let dueDateString = task.taskduedate,
                  let dueDate = convertStringToDate(dateString: dueDateString) else {
                continue
            }
            
            if dueDate > currentDate && task.taskstatus != "Completed" {
                scheduleUpcomingNotificationForTask(task: task, dueDate: dueDate)
            }
            else if dueDate < currentDate && task.taskstatus != "Completed" {
                scheduleOverdueNotificationForTask(task: task, dueDate: dueDate)
            }
        }
    }
    
    func scheduleUpcomingNotificationForTask(task: TaskStatusList, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Task"
    content.body = "Task '\(task.tasktitle ?? "")' is due at '\(task.taskduedate ?? "")'"
        content.sound = UNNotificationSound.default
        
        let triggerDate = dueDate.addingTimeInterval(-10 * 60)  // 10 minutes before the due date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        
        let uniqueIdentifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: uniqueIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling upcoming notification: \(error.localizedDescription)")
            } 
            else {
                print("Upcoming reminder for task \(task.tasktitle ?? "") scheduled successfully")
            }
        }
    }
    
    func scheduleOverdueNotificationForTask(task: TaskStatusList, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Overdue Task"
        content.body = "Task '\(task.tasktitle ?? "")' was due at  and is now overdue."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Immediate trigger
        
        let uniqueIdentifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: uniqueIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling overdue notification: \(error.localizedDescription)")
            } else {
                print("Overdue reminder for task \(task.tasktitle ?? "") scheduled successfully")
            }
        }
    }

    func fetchTaskList() {
        let fetchRequest: NSFetchRequest<TaskList> = TaskList.fetchRequest()
        do {
            self.taskList = try DB_Context.fetch(fetchRequest)
            if self.taskList.isEmpty {
                self.noDataView.isHidden = false
            }
            else {
                self.noDataView.isHidden = true
                self.taskListTableview.reloadData()
            }
        }
        catch {
            print("Failed to fetch TaskCategories: \(error)")
        }
    }
    
    func filterTasksByCategory() {
        if let selectedCategory = selectedCategory {
            filteredData = taskList.filter { task in
                return task.taskcategory == selectedCategory
            }
        } 
        else {
            filteredData = taskList
        }
        
        if filteredData.isEmpty {
            self.noDataView.isHidden = false
            self.taskListTableview.isHidden = true
            self.plusView.isHidden = true
        }
        else {
            self.noDataView.isHidden = true
            self.taskListTableview.isHidden = false
            self.plusView.isHidden = false
        }
        self.taskListTableview.reloadData()
    }
    
    @IBAction func didAllListBtnTap(_ sender: Any) {
        let dropdown = DropDown()
        var categoryList = COREDATA_MANAGER.taskCategories.map { $0.taskcategory_name ?? "" }
        categoryList.insert("All List", at: 0)

        dropdown.dataSource = categoryList
        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            if item == "All List" {
                self?.noDataView.isHidden = true
                self?.taskListTableview.isHidden = false
                self?.plusView.isHidden = false
              
                self?.selectedCategory = nil
                self?.filteredData = self?.taskList ?? []
            }
            else {
                self?.selectedCategory = item
                self?.filterTasksByCategory()
            }
            self?.taskListTableview.reloadData()
            dropdown.hide()
        }
        dropdown.anchorView = sender as? any AnchorView
        dropdown.show()
    }
    
    @IBAction func didSearchBtnTap(_ sender: Any) {
        self.topView.isHidden = true
        self.searchView.isHidden = false
    }
    
    @IBAction func didCancelBtnTap(_ sender: Any) {
        self.searchTextfield.text = ""
        self.topView.isHidden = false
        self.searchView.isHidden = true
        filteredData = taskList
        self.taskListTableview.reloadData()
    }
    
    @IBAction func didAddTaskBtnTap(_ sender: Any) {
        let newTaskPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateTaskPage") as! CreateTaskPage
        self.navigationController?.pushViewController(newTaskPage, animated: false)
    }
    
    @IBAction func didSortBtnTap(_ sender: Any) {
        let dropdown = DropDown()
            dropdown.dataSource = self.sorting
            dropdown.selectionAction = {(index: Int, item: String) in
                switch item {
                case "Due date":
                    // Sort by due date
                    if self.filteredData.isEmpty {
                        self.taskList = self.taskList.sorted { (task1, task2) -> Bool in
                            guard let dueDate1 = self.convertStringToDate(dateString: task1.taskduedate ?? ""),
                                  let dueDate2 = self.convertStringToDate(dateString: task2.taskduedate ?? "") else {
                                return false
                            }
                            return dueDate1 < dueDate2
                        }
                    }
                    else {
                        self.filteredData = self.filteredData.sorted { (task1, task2) -> Bool in
                            guard let dueDate1 = self.convertStringToDate(dateString: task1.taskduedate ?? ""),
                                  let dueDate2 = self.convertStringToDate(dateString: task2.taskduedate ?? "") else {
                                return false
                            }
                            return dueDate1 < dueDate2
                        }
                    }
                    
                case "Priority":
                    if self.filteredData.isEmpty {
                        self.taskList = self.taskList.sorted { (task1, task2) -> Bool in
                            guard let priority1 = task1.taskpriority, let priority2 = task2.taskpriority else {
                                return false
                            }
                            return priority1 < priority2 // Assuming priority is numeric or comparable
                        }
                    }
                    else {
                        self.filteredData = self.filteredData.sorted { (task1, task2) -> Bool in
                            guard let priority1 = task1.taskpriority, let priority2 = task2.taskpriority else {
                                return false
                            }
                            return priority1 < priority2
                        }
                    }
                    
                case "Category":
                    if self.filteredData.isEmpty {
                        self.taskList = self.taskList.sorted { (task1, task2) -> Bool in
                            guard let category1 = task1.taskcategory, let category2 = task2.taskcategory else {
                                return false
                            }
                            return category1 < category2 // Alphabetical sorting (A-Z)
                        }
                    }
                    else {
                        self.filteredData = self.filteredData.sorted { (task1, task2) -> Bool in
                            guard let category1 = task1.taskcategory, let category2 = task2.taskcategory else {
                                return false
                            }
                            return category1 < category2
                        }
                    }
                default:
                    break
                }
                self.taskListTableview.reloadData()
                dropdown.hide()
            }
            self.setDropdownHeight()
            dropdown.anchorView = sender as? any AnchorView
            dropdown.show()
    }
    
}

extension HomePage: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData.isEmpty {
            return taskList.count
        }
        else {
            return filteredData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasklisttableviewcell", for: indexPath) as! tasklisttableviewcell
        let Dict = filteredData.isEmpty ? taskList[indexPath.row] : filteredData[indexPath.row]
        cell.categoryTitleLbl.text = Dict.taskcategory ?? ""
        cell.taskTitleLbl.text = Dict.tasktitle ?? ""
        cell.taskDueDateLbl.text = Dict.taskduedate ?? ""
        cell.taskBtn.tag = indexPath.row
        cell.taskBtn.addTarget(self, action: #selector(taskButtonTapped(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func taskButtonTapped(sender: UIButton) {
        let iDict = self.taskList[sender.tag]
        self.view.endEditing(true)
        let dropdown = DropDown()
        dropdown.dataSource = self.taskStatusList
        dropdown.selectionAction = { (index: Int, item: String) in
            COREDATA_MANAGER.createtaskwithstatus(tasktitle: iDict.tasktitle ?? "", latitude: iDict.latitude, longitude: iDict.longitude, taskduedate: iDict.taskduedate ?? "", taskstatus: item)
            self.fetchTaskStatusList()
            dropdown.hide()
        }
        self.setDropdownHeight()
        dropdown.anchorView = sender
        dropdown.bottomOffset = CGPoint(x: 0, y:(dropdown.anchorView?.plainView.bounds.height)!)
        dropdown.show()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 200
        }
        else {
            return 110
        }
    }
}

class tasklisttableviewcell: UITableViewCell {
    @IBOutlet weak var categoryTitleLbl: UILabel!
    @IBOutlet weak var taskTitleLbl: UILabel!
    @IBOutlet weak var taskDueDateLbl: UILabel!
    @IBOutlet weak var taskBtn: UIButton!
}

extension HomePage: CLLocationManagerDelegate {
    
    func checkLocationAuthorizationStatus() {
        let status = CLLocationManager().authorizationStatus
        print("The status is \(status)")

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            openAppSettings(message: "Your Location permission seems to be disabled, do you want to enable it?", title: "")
        case .authorizedWhenInUse, .authorizedAlways:
            self.makeGeoFence()
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            self.makeGeoFence()
        case .restricted, .denied:
            openAppSettings(message: "Your Location permission seems to be disabled, do you want to enable it?", title: "")
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    func makeGeoFence() {
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100

        for task in self.taskList {
            let taskLatitude = task.latitude
            let taskLongitude = task.longitude
            let taskTitle = task.tasktitle ?? "Unknown Task"

            let geoFenceRegion = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: taskLatitude, longitude: taskLongitude),
                radius: 100,
                identifier: taskTitle
            )
            locationManager.startMonitoring(for: geoFenceRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.makeGeoFence()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendGeofenceNotification(for: region, action: "entered")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendGeofenceNotification(for: region, action: "exited")
    }
    
    func sendGeofenceNotification(for region: CLRegion, action: String) {
        if let circularRegion = region as? CLCircularRegion {
            
            let content = UNMutableNotificationContent()
            content.title = "You \(action) a task area"
            content.body = "You are \(action) the area for task '\(circularRegion.identifier)'."
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: circularRegion.identifier, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
}



