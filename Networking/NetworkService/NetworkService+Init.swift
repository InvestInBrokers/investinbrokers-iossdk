import Foundation
import Alamofire

let kServiceErrorCode = 501

class AlamofireNetworkService: NetworkService {
    
    var manager: SessionManager!
    
    init() {
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "api.klaim.us": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            ),
            "insecure.expired-apis.com": .disableEvaluation
        ]
        
        self.manager = SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
    }

}
