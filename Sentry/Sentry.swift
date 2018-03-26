import Foundation
import Sentry

extension AppDelegate {
    
    func configureSentry() {
        
        do {
            
            Client.shared = try Client(dsn: SENTRY_TOKEN)
            
            try Client.shared?.startCrashHandler()
            
        } catch {}
        
    }
    
}
