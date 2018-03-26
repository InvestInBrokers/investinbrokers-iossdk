import Foundation
import Alamofire

public enum RequestMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

extension URLRequest {
    
    public init?(urlString: String) {
        
        guard let url = URL(string: urlString) else { return nil }

        self.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 300)

    }
    
    // MARK: - GET
    
    public static func GETRequest(urlString: String) -> URLRequest? {

        return URLRequest(urlString: urlString)
    
    }
    
    public static func GETRequest(urlString: String, bodyParameters: [String: Any]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.GET.rawValue
        
        let encoder: URLEncoding = .default
        
        do {
            
            let request = try? encoder.encode(request, with: bodyParameters)
            
            return request
            
        }
   
    }
    
    public static func GETRequestJSON(urlString: String, bodyParameters: [String: Any]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.GET.rawValue
        
        let encoder: JSONEncoding = .default
        
        do {
            
            let request = try? encoder.encode(request, with: bodyParameters)
            
            return request
            
        }
        
    }
    
    // MARK: - POST
    
    public static func POSTRequestJSON(urlString: String, bodyParameters: [String: Any]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
            
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.POST.rawValue
        
        let encoder: JSONEncoding = .default
        
        do {
            
            let request = try? encoder.encode(request, with: bodyParameters)
            
            return request
            
        }
        
    }
    
    public static func POSTRequestURL(urlString: String, bodyParameters: Any) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.POST.rawValue
        
        let encoder: URLEncoding = .default
        
        do {
            
            let request = try? encoder.encode(request, with: bodyParameters as? Parameters)
            
            return request
            
        }
        
    }
    
    public static func POSTRequestData(urlString: String, bodyData: Data? = nil) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.POST.rawValue
        
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = bodyData
        
        return request
        
    }
    
    // MARK: - PUT
    
    public static func PUTRequestJSON(urlString: String, bodyParameters: [String: Any]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.PUT.rawValue
        
        let encoder: JSONEncoding = .default
                
        do {
            
            let request = try? encoder.encode(request, with: bodyParameters)
            
            return request
            
        }
        
    }
      
    public static func PUTRequestData(urlString: String, bodyData: Data?) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
            
        request.httpMethod = RequestMethod.PUT.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = bodyData
            
        return request
     
    }
    
    // MARK: - PATCH
    
    public static func PATCHRequestJSON(urlString: String, bodyParameters: [String: Any]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = RequestMethod.PATCH.rawValue
        
        let encoder: JSONEncoding = .default
        
        do {
            
            let request = try? encoder.encode(request, with: bodyParameters)
            
            return request
            
        }
        
    }

    // MARK: - DELETE
    
    public static func DELETERequest(urlString: String) -> URLRequest? {
        
        var request = URLRequest(urlString: urlString)
        
        request?.httpMethod = RequestMethod.DELETE.rawValue
        
        return request
        
    }

}
