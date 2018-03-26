import UIKit

extension UIViewController {
    
    public func showOkAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.presentViewController(alertController)
        
    }
    
    public func showErrorWith(_ title: String, message: String, completion: @escaping (UIAlertAction) -> ()) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
            completion(action)
            
        }))
        
        self.presentViewController(alertController)
        
    }
    
    public func showContactsAlert(completion: @escaping (UIAlertAction) -> ()) {
        
        let alertController = UIAlertController(title: "To allow “Klaim” to access your Contacts", message: "Go to Settings  >  Klaim  > Enable access to Contacts", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
        
            completion(action)
        
        }))
        
        self.presentViewController(alertController)
        
    }
    
    public func showEmptyPhoneNumberAlert(completion: @escaping (UIAlertAction) -> ()) {
        
        let alertController = UIAlertController(title: "No phone number", message: "There's no phone number for this person in your contact book. Please inform them manually.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            completion(action)
            
        }))
        
        self.presentViewController(alertController)
        
    }
}
