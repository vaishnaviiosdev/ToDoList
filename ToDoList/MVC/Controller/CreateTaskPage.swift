
import UIKit
import Toast_Swift
import CoreLocation
import CoreData
import DropDown

class CreateTaskPage: UIViewController, UITextFieldDelegate {
    
    var priorityLevels = ["Low", "Medium", "High"]
    var latitude:Double?
    var longitude:Double?
    let locationManager = CLLocationManager()
    var taskList: [TaskList] = []
    
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var calenderView: UIView!
    @IBOutlet weak var taskTitleTextfield: UITextField!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTitleLbl: UILabel!
    @IBOutlet weak var descriptionTextfield: UITextField!
    @IBOutlet weak var tickView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskTitleTextfield.delegate = self
        self.locationTextfield.delegate = self
        self.descriptionTextfield.delegate = self
        setRoundCorner(iphone: 25, ipad: 40, customView: self.tickView)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CategorySelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCategorySelected(notification:)), name: NSNotification.Name("CategorySelected"), object: nil)
    }
    
    @objc func handleCategorySelected(notification: Notification) {
        if let userInfo = notification.userInfo, let categoryName = userInfo["categoryName"] as? String {
            self.categoryTitleLbl.textColor = UIColor.white
            self.categoryTitleLbl.text = categoryName
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == taskTitleTextfield {
            locationTextfield.becomeFirstResponder()
        } 
        else if textField == locationTextfield {
            descriptionTextfield.becomeFirstResponder()
        } 
        else if textField == descriptionTextfield {
            descriptionTextfield.resignFirstResponder()
        }
        return true
    }
    
    func setLocation(completion: @escaping (Bool) -> Void) {
        guard let address = self.locationTextfield.text, !address.isEmpty else {
            completion(false)
            return
        }

        geocodeAddress(address: address) { coordinate in
            if let coordinate = coordinate {
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
                completion(true)  // Location successfully set
            } 
            else {
                completion(false)  // Location failed to set
            }
        }
    }
    
    func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(nil)
                return
            }
            if let location = placemarks?.first?.location {
                completion(location.coordinate)
            }
            else {
                completion(nil)
            }
        }
    }
        
    @IBAction func didBackBtnTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func didCalenderBtnTap(_ sender: Any) {
        self.calenderView.isHidden = false
    }
    
    @IBAction func didDoneBtnTap(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMMM yyyy h:mm a"  // Format: Sat, 8 March 2025
        self.dateLbl.textColor = UIColor.white
        self.dateLbl.text = dateFormatter.string(from: self.datePicker.date)
        self.calenderView.isHidden = true
    }
    
    @IBAction func didSelectPriorityBtnTap(_ sender: Any) {
        self.view.endEditing(true)
        let dropdown = DropDown()
        dropdown.dataSource = self.priorityLevels
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.priorityLabel.textColor = UIColor.white
            self.priorityLabel.text = item
            dropdown.hide()
        }
        
        self.setDropdownHeight()
        dropdown.anchorView = sender as? any AnchorView
        dropdown.bottomOffset = CGPoint(x: 0, y:(dropdown.anchorView?.plainView.bounds.height)!)
        dropdown.show()
    }
    
    @IBAction func didSelectCategoryBtnTap(_ sender: Any) {
        let newTaskPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskCategoryPage") as! TaskCategoryPage
        self.present(newTaskPage, animated: true)
    }
    
    @IBAction func didCreateTaskBtnTap(_ sender: Any) {
        if self.taskTitleTextfield.text == "" || self.taskTitleTextfield.text == nil {
            self.view.makeToast("Please enter the title")
        }
        else if self.locationTextfield.text == "" || self.locationTextfield.text == nil {
            self.view.makeToast("Please enter the location")
        }
        else if self.descriptionTextfield.text == "" || self.descriptionTextfield.text == nil {
            self.view.makeToast("Please enter the description")
        }
        else if self.dateLbl.text == "" || self.dateLbl.text == nil || self.dateLbl.text == "Select your priority level" {
            self.view.makeToast("Select the due date")
        }
        else if self.priorityLabel.text == "" || self.priorityLabel.text == nil || self.priorityLabel.text == "Select your priority level" {
            self.view.makeToast("Select the priority level")
        }
        else if self.categoryTitleLbl.text == "" || self.categoryTitleLbl.text == nil || self.categoryTitleLbl.text == "Select your Category" {
            self.view.makeToast("Select the category")
        }
        else {
            setLocation { success in
                if success {
                    COREDATA_MANAGER.createTask(
                        title: self.taskTitleTextfield.text ?? "",
                        latitude: self.latitude ?? 0.0,
                        longitude: self.longitude ?? 0.0,
                        description: self.descriptionTextfield.text ?? "",
                        dueDate: self.dateLbl.text ?? "",
                        priority: self.priorityLabel.text ?? "",
                        categoryName: self.categoryTitleLbl.text ?? ""
                    )
                    self.view.makeToast("Task Created Successfully")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    self.view.makeToast("Failed to get location coordinates.")
                }
            }
        }
    }
}




