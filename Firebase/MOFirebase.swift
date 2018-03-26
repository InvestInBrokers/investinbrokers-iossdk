import Foundation
import FirebaseAuth
import FirebaseCore

class MOFirebase {
    
    func authenticate(countryCode: String, phoneNumber: String, completion: VerificationResultCallback?) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(countryCode + phoneNumber, completion: completion)
        
    }
    
    func signIn(verificationID: String, verifyCode: String, completion: AuthResultCallback?) {
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verifyCode)
        
        Auth.auth().signIn(with: credential, completion: completion)
        
    }
    
}

extension UIViewController {    
    
    func logout() {
        
        let firebaseAuth = Auth.auth()
        
        do {
            
            try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
            
        }
        
    }
    
}

extension AppDelegate {
    
    func setAPNS(token: Data) {
        
        Auth.auth().setAPNSToken(token, type: AuthAPNSTokenType.prod)
        
    }
    
    func configureFirebase() {
        
        FirebaseApp.configure()

    }
    
    func canHandleNotification(userInfo: [AnyHashable : Any]) -> Bool {
        
        return Auth.auth().canHandleNotification(userInfo)
        
    }

}
