
import Foundation
import UIKit
import DropDown

var activityIndicator: UIActivityIndicatorView!

extension NSObject {
    
    func setView(iview: UIView, customColor: UIColor, borderWidth: CGFloat) {
        iview.layer.cornerRadius = iview.frame.height / 2
        iview.layer.borderWidth = borderWidth
        iview.layer.borderColor = customColor.cgColor
    }
    
    func setRoundCorner(iphone:CGFloat,ipad:CGFloat,customView:UIView) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            customView.layer.cornerRadius = iphone
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            customView.layer.cornerRadius = ipad
        }
    }
    
    func setDropdownHeight() {
        let dropdown = DropDown()
        if UIDevice.current.userInterfaceIdiom == .pad {
            dropdown.cellHeight = 80
            dropdown.textFont = UIFont.systemFont(ofSize: 24)
            dropdown.selectionBackgroundColor = UIColor.appPrimary
        }
        else {
            dropdown.cellHeight = 40
            dropdown.textFont = UIFont.systemFont(ofSize: 16)
        }
    }
    
    public func TopMostViewController() -> UIViewController {
            return self.TopMostViewController(withRootViewController: (UIApplication.shared.keyWindow?.rootViewController!)!)
            //UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    
    public func TopMostViewController(withRootViewController rootViewController: UIViewController) -> UIViewController {
        if (rootViewController is UITabBarController) {
            let tabBarController = (rootViewController as! UITabBarController)
            return self.TopMostViewController(withRootViewController: tabBarController.selectedViewController!)
        }
        else if (rootViewController is UINavigationController) {
            let navigationController = (rootViewController as! UINavigationController)
            return self.TopMostViewController(withRootViewController: navigationController.visibleViewController!)
        }
        else if rootViewController.presentedViewController != nil {
            let presentedViewController = rootViewController.presentedViewController!
            return self.TopMostViewController(withRootViewController: presentedViewController)
        }
        else {
            return rootViewController
        }
    }
    
    func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMMM yyyy h:mm a"  // Adjust based on your Core Data format
        return dateFormatter.date(from: dateString)
    }
        
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMMM yyyy h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func openAppSettings(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(1)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        TopMostViewController().present(alertController, animated: true, completion: nil)
    }
}

