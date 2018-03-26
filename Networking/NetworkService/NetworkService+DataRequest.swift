import Foundation
import Alamofire

public protocol MOOperation {
    
    func cancel()

}

extension AlamofireNetworkService {

    func enqueueNetworkRequest(request: NetworkRequest) -> MOOperation? {
        
        let alamofireRequest = self.manager.request(request.urlRequest)
        
        let alamofireRequestOperation = AlamoFireRequestOperation(request: alamofireRequest)
        
        let completion = completionForRequest(request: request)
        
        alamofireRequestOperation.fire(completion: completion)
        
        return alamofireRequestOperation
        
    }
 
}

struct AlamoFireRequestOperation: MOOperation {
    
    private let request: DataRequest
    
    init(request: DataRequest) {
        self.request = request
    }
    
    func fire(completion: @escaping DataResponseCompletion) {
        
        request.validate().responseData { (data) in
            
            self.log.verbose(message: "Request response for URL: \(String(describing: self.request.request!.url))")

            self.handleResponse(networkResponse: data, completion: completion)
            
        }
        
    }
    
    func cancel() {
        
        request.cancel()
    
    }
}

extension MOOperation {
    
    var log: Logger { return LoggerFactory.logger() }
    
    func handleResponse(networkResponse: DataResponse<Data>, completion: DataResponseCompletion) {
        
        var errorOptional: NSError? = nil
        
        switch networkResponse.result {
            
        case .success:
            
            let response = networkResponse.response!
            
            self.log.info(message: "Received succses response \(response.statusCode)")
            
        case .failure(let error):
            
            if let response = networkResponse.response {
                
                self.log.info(message: "Received error response \(response.statusCode)")
                
                let userInfo = ["response": response, NSUnderlyingErrorKey: error] as [String : Any]
                
                errorOptional = NSError(domain: "RequestOperation", code: response.statusCode, userInfo: userInfo)
                
            } else {
                
                let userInfo = [NSUnderlyingErrorKey: error]
                
                errorOptional = NSError(domain: "RequestOperation", code: error._code, userInfo: userInfo)
            }
        }
        
        completion(networkResponse.data, errorOptional)
        
    }
}
