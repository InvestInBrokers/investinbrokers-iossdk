import Foundation
import UIKit

extension UIStoryboard {
    
    public class func controllerWithIdentifier(identifier: String, storyboard: String) -> Any {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: identifier)
    
    }
    
}
