import UIKit

protocol Reusable {
    
    static var identifier: String { get }

}

extension Reusable {

    static var identifier: String {
    
        return String(describing: self)
    
    }

}

extension UITableView {
    
    func registerNib<T: UITableViewCell>(_ nib: T.Type) where T: Reusable {
        
        register(UINib(nibName: T.identifier, bundle: nil), forCellReuseIdentifier: T.identifier as String)
        
    }
    
    func registerClass<T: UITableViewCell>(_ aClass: T.Type) where T: Reusable {
   
        register(aClass, forCellReuseIdentifier: T.identifier)
    
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type) -> T where T: Reusable {
        
        return (self.dequeueReusableCell(withIdentifier: T.identifier) as? T)!

    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type, indexPath: IndexPath) -> T where T: Reusable {

        return (self.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T)!
    
    }

}
