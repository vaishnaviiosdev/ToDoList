
import Foundation
import CoreData


extension TaskCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCategory> {
        return NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
    }

    @NSManaged public var task_image: String?
    @NSManaged public var taskcategory_name: String?

}

extension TaskCategory : Identifiable {

}
