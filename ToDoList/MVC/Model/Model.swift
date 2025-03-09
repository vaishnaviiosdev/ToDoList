
import Foundation
import SwiftyJSON

class categoryModel {
    
    var task_image: String!
    var task_name: String!
   
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        task_name = json["task_name"].stringValue
        task_image = json["task_image"].stringValue
    }
    
}






