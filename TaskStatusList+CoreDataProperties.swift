
import Foundation
import CoreData


extension TaskStatusList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskStatusList> {
        return NSFetchRequest<TaskStatusList>(entityName: "TaskStatusList")
    }

    @NSManaged public var tasktitle: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var tasklocation: String?
    @NSManaged public var taskduedate: String?
    @NSManaged public var taskstatus: String?

}

extension TaskStatusList : Identifiable {

}
