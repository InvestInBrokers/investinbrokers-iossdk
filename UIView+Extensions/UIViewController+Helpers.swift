
import Foundation
import UIKit

public enum UIViewControllerTransition {
    
    case flowFromRight
    case pushToBack

}

extension UIViewController {
    
    public var navController: UINavigationController {
        
        get {
        
            return self.navigationController!
       
        }
    
    }

    public func setRightButtonItem(_ item: UIBarButtonItem?) {
        
        self.navigationItem.rightBarButtonItem = item
    
    }
    
    public func setLeftButtonItem(_ item: UIBarButtonItem?) {
        
        self.navigationItem.leftBarButtonItem = item
    
    }
    
    public func pushViewController(_ viewController: UIViewController) {
        
        self.navigationController?.pushViewController(viewController, animated: true)
    
    }
    
    public func insertViewController(_ controller: UIViewController, belowViewController: UIViewController, withTransition: UIViewControllerTransition, duration: TimeInterval) {
        
         
    }
    
    public func presentViewControllerNonAnimated(_ viewController: UIViewController) {
        
        self.present(viewController, animated: false, completion: nil)
    
    }

    public func presentViewController(_ viewController: UIViewController) {
        
        self.present(viewController, animated: true, completion: nil)
    
    }
    
    public func dismissViewController() {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    public func addViewController(_ viewController: UIViewController, inView:UIView) {
        
        self.addViewController(viewController, inView: inView, underView:nil, parentController:self)
    
    }
    
    public func addViewController(_ viewController: UIViewController, inView:UIView, fromController:UIViewController) {
        
        self.addViewController(viewController, inView: inView, underView: nil, parentController: fromController)
    
    }
    
    public func removeViewController(_ viewController: UIViewController) {
        
        viewController.willMove(toParentViewController: nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParentViewController()
 
    }
    
    public func addViewController(_ viewController: UIViewController, inView:UIView, underView:UIView?, parentController:UIViewController) {
        
        viewController.willMove(toParentViewController: parentController)
        
        parentController.addChildViewController(viewController)
        
        viewController.view.frame = inView.frame
        
        if let topView = underView {
            
            inView.insertSubview(viewController.view, belowSubview:topView)
            
        } else {
            
            inView.addSubview(viewController.view)
        
        }
        
        let myView = viewController.view
        
        myView?.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict: [String: UIView] = ["myView": myView!]
        
        let constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[myView]-0-|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: viewDict)
        
        let constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[myView]-0-|",
            options:[NSLayoutFormatOptions.alignAllLeft, NSLayoutFormatOptions.alignAllRight], metrics: nil, views: viewDict)
        
        inView.addConstraints(constraint1)
        inView.addConstraints(constraint2)
        
        viewController.didMove(toParentViewController: parentController)
        
    }
    
    public func popToViewController(_ viewController: UIViewController.Type) {
        
        if let viewControllers = self.navigationController?.viewControllers {
            
            for vc in viewControllers {
                                
                if vc.isKind(of: viewController) {
                    
                    self.navigationController!.popToViewController(vc, animated: true)
                    
                }
                
            }
            
        }

    }
    
    public func rootViewController() -> UIViewController {
        
        let window: UIWindow = UIApplication.shared.windows[0] 
        
        return window.rootViewController!

    }

}

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
        
            return topViewController(controller: navigationController.visibleViewController)
        
        }
        
        if let tabController = controller as? UITabBarController {
        
            if let selected = tabController.selectedViewController {
            
                return topViewController(controller: selected)
            
            }
        
        }
        
        if let presented = controller?.presentedViewController {
        
            return topViewController(controller: presented)
        
        }
            
        return controller

    }
    
}
