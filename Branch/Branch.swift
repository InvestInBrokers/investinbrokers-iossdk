import Foundation
import Branch

var kInvited: [String: String] = [:]

let kInvited_by = "invited_by"
let kInvited_by_id = "invited_by_id"
let kInvited_type = "invited_type"

class MOBranch {
    
    class var branch: Branch {
        
        get {
            
            let context = Branch.getInstance()
            
            return context!
        
        }
        
    }
    
    class func initSession(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        self.branch.initSession(launchOptions: launchOptions, automaticallyDisplayDeepLinkController: true, deepLinkHandler: { params, error in
            
            if error == nil {
                
                guard let clicked = params?["+clicked_branch_link"] as? Bool, clicked else { return }
                
                guard let invited_by = params?[kInvited_by] as? String else { return }
                
                guard let invited_by_id = params?[kInvited_by_id] as? String else { return }
                
                guard let invited_type = params?[kInvited_type] as? String else { return }

                kInvited[kInvited_by] = invited_by
                
                kInvited[kInvited_by_id] = invited_by_id
                
                kInvited[kInvited_type] = invited_type
                
            }
            
        })
        
    }
    
    class func createDeepLink(user: User, type: String, completion: @escaping StringCompletion) {
        
        let branchObject = BranchUniversalObject()
        branchObject.title = "Klaim"
        
        if let firstName = user.person?.first_name, let lastName = user.person?.last_name, let id = user.id {
            
            let name = firstName.appending(" ").appending(lastName)
            
            branchObject.addMetadataKey(kInvited_by, value: name)
         
            branchObject.addMetadataKey(kInvited_by_id, value: id)
        
            branchObject.addMetadataKey(kInvited_type, value: type)
            
        }
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        linkProperties.channel = "invite"
        linkProperties.addControlParam("$desktop_url", withValue: BRANCH_URL)
        linkProperties.addControlParam("$ios_url", withValue: BRANCH_URL)
        
        branchObject.getShortUrl(with: linkProperties) { urlOptional, errorOptional in
            
            if let urlStrong = urlOptional {
                
                completion(urlStrong)
                
            } else {
                
                completion("klaim.us")
                
            }
            
        }
        
    }
    
    class func completedAction(title: String) {
        
        self.branch.userCompletedAction(title)
        
    }
    
}
