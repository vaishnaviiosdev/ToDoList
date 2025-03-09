
import Foundation
import CoreData


extension TaskList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskList> {
        return NSFetchRequest<TaskList>(entityName: "TaskList")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var taskcategory: String?
    @NSManaged public var taskdescription: String?
    @NSManaged public var taskduedate: String?
    @NSManaged public var tasklocation: String?
    @NSManaged public var taskpriority: String?
    @NSManaged public var tasktitle: String?

}

extension TaskList : Identifiable {

}
