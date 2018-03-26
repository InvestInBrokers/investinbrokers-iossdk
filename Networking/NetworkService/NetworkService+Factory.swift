import Foundation

let kNetworkServiceClass = "NetworkService"

public class NetworkServiceFactory {
    
    private static var serviceInstance: NetworkService?
    private static var authenticatedNetworkServiceInstance: AuththenticatedNetworkService?
    
    public static func networkService() -> NetworkService {
        
        if serviceInstance == nil {
            
            serviceInstance = setupNetworkService()
        }
        
        return serviceInstance!
    }
    
    public static func authenticatedNetworkService() -> AuththenticatedNetworkService {
        
        if authenticatedNetworkServiceInstance == nil {
            
            let userDefaults = UserDefaultsImpl()
            
            authenticatedNetworkServiceInstance = AuththenticatedNetworkService(networkService: networkService(), userDefaults: userDefaults)
        }
        
        return authenticatedNetworkServiceInstance!
    }
    
    private static func setupNetworkService() -> NetworkService {
        
        let networkService: NetworkService
        
        let infoDictionary = Bundle.main.infoDictionary
        
        let networkClass = infoDictionary![kNetworkServiceClass] as? String ?? "NetworkService"
        
        switch(networkClass) {
            
        case "MockNetworkServiceImpl":
            
            networkService = MockNetworkService()
            
            break
            
        default:
            
            networkService = AlamofireNetworkService()
            
        }
        
        return networkService
 
    }
}
