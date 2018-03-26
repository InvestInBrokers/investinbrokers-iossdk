import Foundation
import UserNotifications

protocol NotificationDelegate {
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: String)
    
    func didFailToRegisterForRemoteNotificationsWithError(error: Error)
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any])
    
}

let notify = Notification.Name("NotificationIdentifier")

class NotificationCoordinator {
    
    var notificationService: NotificationService
    
    var userEmailService: UserEmailService
    
    var userDefaults: MOUserDefaults
    
    var presented: Bool = false
    
    init(notificationService: NotificationService, userEmailService: UserEmailService, userDefaults: MOUserDefaults) {
        
        self.notificationService = notificationService
     
        self.userEmailService = userEmailService
        
        self.userDefaults = userDefaults
        
    }
    
    func getNotificationsStatus() -> Bool {
        
        return UIApplication.shared.isRegisteredForRemoteNotifications
        
    }
    
    func performDeviceRegistrationIfRequired() {
        
        self.registerForNotifications()
        
    }
    
    private func registerForNotifications() {
        
        if #available(iOS 10, *) {
            
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) {
                granted, error in
                
                if !granted {
                    
                    self.postNotification()
                    
                }
                
            }
            
            UIApplication.shared.registerForRemoteNotifications()
            
        } else if #available(iOS 9, *) {
            
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            
            UIApplication.shared.registerForRemoteNotifications()
            
            self.checkAccess()
            
        }
    
    }

    private func checkAccess() {
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { notification in
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                
                if UIApplication.shared.isRegisteredForRemoteNotifications == false {
                    
                    if self.presented { return }
                    
                    self.presented = true
                    
                    self.postNotification()
                    
                }
                
            })
           
        }
        
    }
    
    func registerDeviceWithDeviceToken(id: String, parameters: String, deviceToken: String) {
        
        self.notificationService.postDeviceToken(id: id, parameters: parameters, token: deviceToken) { errorOptional in
            
            if let _ = errorOptional {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    
                    self.registerDeviceWithDeviceToken(id: id, parameters: parameters, deviceToken: deviceToken)
                    
                })
                
            } else {
                
                self.updateNotificationsStatus(id: id, status: true, parameters: parameters)
                
            }
            
        }
        
    }
    
    private func updateNotificationsStatus(id: String, status: Bool, parameters: String) {
        
        self.userEmailService.putUserNotificationsStatus(id: id, status: status, parameters: parameters) { errorOptional in
            
            if let _ = errorOptional {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    
                    self.updateNotificationsStatus(id: id, status: status, parameters: parameters)
                    
                })
                
            } else {
                
                self.postNotification()
                
            }
            
        }
        
    }
    
    private func postNotification() {
        
        let isInitialized = self.userDefaults.boolForKey(kAppInitialized)
        
        if isInitialized == nil || isInitialized == false  {
            
            NotificationCenter.default.post(name: notify, object: nil)
            
        }

    }
    
    func receiveRemoteNotification(_ alert: String) {
        
        self.showLocalNotification(alert)
        
    }
    
    //MARK: Helpers
    
    private func showLocalNotification(_ alert: String) {
        
        print(alert)
        
    }
    
}
