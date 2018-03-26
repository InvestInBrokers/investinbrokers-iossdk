import Foundation
import Alamofire
import Sentry
import FirebaseAuth

fileprivate let SESSION_URL = BASE_URL + "/user/session/firebase"
fileprivate let SESSION_SINCH_URL = BASE_URL + "/user/session/sinch"

/// Used as a key for refresh token
public let kRefreshTokenKey = "refreshToken"

/// Used as a key for request headers
let kAuthorization = "Authorization"

public protocol AuththenticatedNetworkServiceDelegate: class {
    
    func authenticatedNetworkServiceShouldReAuthenticate(service: AuththenticatedNetworkService) -> Bool
    
    func authenticatedNetworkServiceURLForAuthentication(service: AuththenticatedNetworkService) -> String
    
    func authenticatedNetworkService(service: AuththenticatedNetworkService, didReauthenticateWithToken: String)
    
    func authenticatedNetworkService(service: AuththenticatedNetworkService, failedToAuthenticateWithToken: String)
 
    func authenticatedNetworkServiceTimeout(service: AuththenticatedNetworkService)
    
    func authenticatedNetworkServiceConnected(service: AuththenticatedNetworkService)
    
}

public class AuththenticatedNetworkService: NetworkService {
    
    public weak var delegate: AuththenticatedNetworkServiceDelegate?
    
    let networkService: NetworkService
    
    let userDefaults: MOUserDefaults
    
    let sessionManager: SessionManager
    
//    var count = 10
    
    public init(networkService: NetworkService, userDefaults: MOUserDefaults) {
        
        self.networkService = networkService
       
        self.userDefaults = userDefaults
        
        self.sessionManager = SessionManager.default
        
    }
    
    public func enqueueNetworkRequest(request: NetworkRequest) -> MOOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        let authenticatedCheckTask = DataRequestTask(urlRequest: request.urlRequest, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkRequest(request: authenticatedCheckTask)
        
//        self.count = 10
        
//        self.countDown()
     
        return operation
    
    }
    
//    private func countDown() {
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//            if self.count == 0 {
//
//                self.delegate?.authenticatedNetworkServiceTimeout(service: self)
//
//            } else if self.count > 0 {
//
//                self.count -= 1
//
//                self.countDown()
//
//            }
//
//        }
//
//    }
    
    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest, fileURL: URL) -> UploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: request.urlRequest, name: request.name, fileName: request.fileName, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(request: authenticatedCheckTask, fileURL: fileURL)
        
        return operation
        
    }
    
    public func enqueueNetworkUploadRequest(request: NetworkUploadRequest, data: Data) -> UploadOperation? {
        
        let taskCompletion = authenticatedCheckResponseHandler(request: request)
        
        let authenticatedCheckTask = DataUploadTask(urlRequest: request.urlRequest, name: request.name, fileName: request.fileName, mimeType: request.mimeType, taskCompletion: taskCompletion)
        
        let operation = networkService.enqueueNetworkUploadRequest(request: authenticatedCheckTask, data: data)
        
        return operation
        
    }
    
    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
        
        return nil
        
    }
    
    //    public func enqueueNetworkDownloadRequest(request: NetworkDownloadRequest) -> DownloadOperation? {
    //
    //        let taskCompletion: ErrorCompletion = { errorOptional in
    //
    //        }
    //
    //        let downloadCompletion: DownloadCompletion = { fileLocation in
    //
    //        }
    //
    //        let progressCompletion: DownloadProgressCompletion = {_,_,_ in
    //
    //        }
    //
    //        return nil
    //
    //    }
    
    func authenticatedCheckResponseHandler(request: NetworkRequest) -> DataResponseCompletion {
        
        let taskCompletion: DataResponseCompletion = {
            
            (dataOptional: Data?, errorOptional: Error?)  in
            
//            self.count = -10
            
            if let error = errorOptional {
                
                if self.validateToken(request: request) {
                
                    switch error._code {
                        
                    case NSURLErrorTimedOut:
                        
                        self.delegate?.authenticatedNetworkServiceTimeout(service: self)
                        
                        if let url = request.urlRequest.url?.absoluteString {
                            
                            let event = Event(level: .warning)
                            
                            event.message = "Timeout - \(url)"
                            
                            Client.shared?.send(event: event)
                            
                        }
                        
                        request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                        
                    case 401:
                        
                        self.handleAuthtenticationErrorForTask(networkRequest: request)
                        
                    case 403:
                        
                        self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: "")
                        
                    case 503:
                        
                        if let url = request.urlRequest.url?.absoluteString {
                            
                            let event = Event(level: .warning)
                            
                            event.message = "Timeout throttling - \(url)"
                            
                            Client.shared?.send(event: event)
                            
                        }
                        
                        request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                        
                    default:
                        
                        request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                        
                    }
                    
                } else {
                    
                    if error._code != 404 {
                        
                        let event = Event(level: .warning)
                        
                        event.message = "Wrong token"
                        
                        Client.shared?.send(event: event)
                        
                        self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: "")
                        
                    } else {
                        
                        request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                        
                    }
                    
                }
                
            } else {
                
                request.handleResponse(dataOptional: dataOptional, errorOptional: errorOptional)
                
                self.delegate?.authenticatedNetworkServiceConnected(service: self)
                
            }
        
        }
        
        return taskCompletion
    }
    
    func validateToken(request: NetworkRequest) -> Bool {

        var success = false

        if let token = request.urlRequest.value(forHTTPHeaderField: kAuthorization),
            let userID = self.appContext.user()?.id {

            success = token.getJwtBodyString(userID: userID)

        }

        return success

    }
    
    func handleAuthtenticationErrorForTask(networkRequest: NetworkRequest) {
        
        guard let type = self.userDefaults.stringForKey(k_verification_type) else { return }
        
        if type == VerificationType.Firebase.rawValue {
            
            if Auth.auth().currentUser == nil {
                
                let event = Event(level: .warning)
                
                event.message = "Firebase refresh token error - firebase user is nil"
                
                Client.shared?.send(event: event)
                
                self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: "")
                
            } else {
                
                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { token, error in
                    
                    if let _ = error {
                        
                        let event = Event(level: .warning)
                        
                        event.message = "Firebase refresh token error"
                        
                        Client.shared?.send(event: event)
                        
                        self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: "")
                        
                    } else {
                        
                        self.createSession(token: token!, networkRequest: networkRequest)
                        
                    }
                    
                })
                
            }
            
        } else {
            
            self.createSessionWithSinch(networkRequest: networkRequest)
            
        }
        
    }
    
    func createSession(token: String, networkRequest: NetworkRequest) {
        
        guard let id = self.appContext.user()?.id else {
            
            self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: "")
            
            return
            
        }
        
        let pathParameters = [k_user_id: id]
        
        let url = SESSION_URL.URLReplacingPathParamaters(parameters: pathParameters)
        
        let bodyParameters = [k_id_token: token, k_environment: ENVIRONMENT]
        
        if let request = URLRequest.POSTRequestJSON(urlString: url, bodyParameters: bodyParameters) {
            
            let taskCompletion = self.refreshTokenResponseHandler(initialNetworkRequest: networkRequest)
            
            let task = JSONRequestTask(urlRequest: request, taskCompletion: taskCompletion)
            
            _ = self.networkService.enqueueNetworkRequest(request: task)
            
        }
        
    }
    
    /// Used to create user session with sinch
    private func createSessionWithSinch(networkRequest: NetworkRequest) {
        
        let id = UIDevice.current.identifierForVendor!.uuidString
        
        guard let phone_number = self.userDefaults.stringForKey(k_phone_number) else {
            
            self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: "")
            
            return
            
        }
        
        let bodyParams = [k_id: id, k_phone_number: phone_number, k_environment : ENVIRONMENT]
        
        print(bodyParams)
        
        if let request = URLRequest.POSTRequestJSON(urlString: SESSION_SINCH_URL, bodyParameters: bodyParams) {
            
            let taskCompletion = self.refreshTokenResponseHandler(initialNetworkRequest: networkRequest)
            
            let task = JSONRequestTask(urlRequest: request, taskCompletion: taskCompletion)
            
            _ = self.networkService.enqueueNetworkRequest(request: task)
            
        }
        
    }
    
    func refreshTokenResponseHandler(initialNetworkRequest: NetworkRequest) -> JSONResponseCompletion {
        
        let refreshToken = userDefaults.secureStringForKey(k_access_token)
        
        let taskCompletion: JSONResponseCompletion = {
            
            (responseOptional: Any?, errorOptional: Error?) in
            
            if errorOptional == nil {
                
                if let dictionary = responseOptional as? [String: Any] {
                    
                    if let access_token = dictionary[k_access_token] as? String {
                        
                        let standard = "Bearer "
                        
                        self.userDefaults.setSecureString(standard + access_token, forKey: k_access_token)
                                                
                        self.delegate?.authenticatedNetworkService(service: self, didReauthenticateWithToken: access_token)

                    }
                    
                }
                
                var mutableRequest = initialNetworkRequest

                if let tokens = self.userDefaults.secureStringForKey(k_access_token) {

                    mutableRequest.urlRequest.setValue(tokens, forHTTPHeaderField: kAuthorization)

                    _ = self.networkService.enqueueNetworkRequest(request: mutableRequest)

                } else {
                    
                    self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: refreshToken!)
                    
                    mutableRequest.handleResponse(dataOptional: nil, errorOptional: errorOptional)
                
                }
                
            } else {
                
                let event = Event(level: .warning)
                
                event.message = "Refresh session error"
                
                Client.shared?.send(event: event)
                
                self.delegate?.authenticatedNetworkService(service: self, failedToAuthenticateWithToken: refreshToken!)
                
                initialNetworkRequest.handleResponse(dataOptional: nil, errorOptional: errorOptional)
            
            }
            
        }
        
        return taskCompletion
    
    }
  
}
