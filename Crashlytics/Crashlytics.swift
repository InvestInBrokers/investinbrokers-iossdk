import Foundation
import Fabric
import Crashlytics

extension AppDelegate {
    
    func configureFabric() {
        
        Fabric.sharedSDK().debug = true
        
        Fabric.with([Crashlytics.self])
        
    }
    
}
